import Combine
import Foundation
import SwiftUI

// MARK: - SalonProfileViewModel

@MainActor
final class SalonProfileViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        let didTapBack: () -> Void
        let didRequireAuth: () -> Void
        let didRequestBooking: (_ salon: Salon, _ entry: SalonBookingEntry, _ availableServiceIds: Set<String>) -> Void
    }

    // MARK: - Share sheet presentation model

    struct ShareSheetPresentation: Identifiable {
        let id = UUID()
        let url: URL
        let title: String
    }

    // MARK: - Published State

    @Published private(set) var salon: Salon?
    @Published var selectedTab: Int = 0
    @Published var servicesSearchQuery: String = ""
    @Published var specialistsSearchQuery: String = ""
    @Published private(set) var isFavorited: Bool = false
    @Published var shareSheet: ShareSheetPresentation?

    /// Ids of services the salon can actually book (Altegio only). `nil` until
    /// loaded; drives filtering of the Services tab and is handed to the booking
    /// flow. Non-Altegio salons leave this `nil` (no availability concept).
    @Published private(set) var availableServiceIds: Set<String>?
    @Published private(set) var isLoadingAvailability: Bool = false

    /// Ids of workers the salon can actually book (Altegio only). `nil` until
    /// loaded; drives filtering of the Specialists tab. Non-Altegio salons leave
    /// this `nil` (no availability concept → show every worker).
    @Published private(set) var availableWorkerIds: Set<String>?
    @Published private(set) var isLoadingWorkers: Bool = false

    /// Currently-highlighted slot time per worker id (defaults to the nearest).
    /// Bound by each specialist row; the chosen slot's datetime is carried into
    /// the booking flow.
    @Published var selectedSlotByWorker: [String: String] = [:]

    /// Next available slots per worker id (Altegio, when loaded). Backs the slot
    /// pills + nearest-date label and resolves the datetime carried forward.
    private var workerSlots: [String: [AltegioBookingSlot]] = [:]

    // MARK: - Dependencies

    private let salonId: String
    private let transition: Transition
    private let getSalonByIdUseCase: any GetSalonByIdUseCase
    private let getSalonShareUseCase: any GetSalonShareUseCase
    private let getAltegioAvailableServicesUseCase: any GetAltegioAvailableServicesUseCase
    private let getAltegioAvailableWorkersUseCase: any GetAltegioAvailableWorkersUseCase
    private let saveSalonUseCase: any SaveSalonUseCase
    private let unsaveSalonUseCase: any UnsaveSalonUseCase
    private let savedSalonsEventBus: any SavedSalonsEventBus
    private let sessionManager: SessionManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        salonId: String,
        transition: Transition,
        getSalonByIdUseCase: any GetSalonByIdUseCase,
        getSalonShareUseCase: any GetSalonShareUseCase,
        getAltegioAvailableServicesUseCase: any GetAltegioAvailableServicesUseCase,
        getAltegioAvailableWorkersUseCase: any GetAltegioAvailableWorkersUseCase,
        saveSalonUseCase: any SaveSalonUseCase,
        unsaveSalonUseCase: any UnsaveSalonUseCase,
        savedSalonsEventBus: any SavedSalonsEventBus,
        sessionManager: SessionManager
    ) {
        self.salonId = salonId
        self.transition = transition
        self.getSalonByIdUseCase = getSalonByIdUseCase
        self.getSalonShareUseCase = getSalonShareUseCase
        self.getAltegioAvailableServicesUseCase = getAltegioAvailableServicesUseCase
        self.getAltegioAvailableWorkersUseCase = getAltegioAvailableWorkersUseCase
        self.saveSalonUseCase = saveSalonUseCase
        self.unsaveSalonUseCase = unsaveSalonUseCase
        self.savedSalonsEventBus = savedSalonsEventBus
        self.sessionManager = sessionManager
        super.init()
        observeSavedSalonsBus()
    }

    // MARK: - Lifecycle

    override func onViewTask() async {
        // `.task` re-runs every time the screen reappears (e.g. popping back from
        // SelectService). Load only once — keep the salon + availability we
        // already fetched instead of re-hitting the API (incl. the slow CRM call).
        guard salon == nil else { return }
        await loadSalon()
    }

    // MARK: - Computed

    var filteredServices: [SalonService] {
        guard let salon else { return [] }
        var services = salon.services
        // Altegio salons only surface services the salon can actually book.
        if salon.provider == .altegio, let availableServiceIds {
            services = services.filter { availableServiceIds.contains($0.id) }
        }
        let q = servicesSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return services }
        return services.filter { service in
            service.name.localizedCaseInsensitiveContains(q)
                || (service.description?.localizedCaseInsensitiveContains(q) ?? false)
        }
    }

    // Suppresses the "nothing found" message while availability is still loading.
    var servicesTabIsEmpty: Bool {
        isLoadingAvailability ? false : filteredServices.isEmpty
    }

    var filteredWorkers: [SalonWorker] {
        guard let salon else { return [] }
        var workers = salon.workers
        // Altegio salons only surface workers the salon can actually book.
        if salon.provider == .altegio, let availableWorkerIds {
            workers = workers.filter { availableWorkerIds.contains($0.id) }
        }
        let q = specialistsSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return workers }
        return workers.filter { worker in
            let fullName = "\(worker.firstName) \(worker.lastName)"
            return fullName.localizedCaseInsensitiveContains(q)
                || (worker.position?.localizedCaseInsensitiveContains(q) ?? false)
        }
    }

    // Suppresses the "nothing found" message while availability is still loading
    // or when only the "any specialist" option would show.
    var specialistsTabIsEmpty: Bool {
        if isLoadingWorkers { return false }
        return filteredWorkers.isEmpty && !showsAnySpecialistOption
    }

    // The "Будь-який" (any specialist) option leads the Specialists list for the
    // in-app (Altegio) flow. Hidden while searching by name.
    var showsAnySpecialistOption: Bool {
        salon?.provider == .altegio
            && specialistsSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // EasyWeek salons are browse-only in-app (booking happens in the web widget),
    // so per-row "Add"/"Select" actions are hidden for them.
    var showsRowActions: Bool {
        salon?.provider != .easyweek
    }

    var optionsCount: Int {
        switch selectedTab {
        case 0: return filteredServices.count
        case 1: return filteredWorkers.count
        default: return 0
        }
    }

    // MARK: - Presentation row models

    func serviceRowModel(for service: SalonService) -> ServiceModel {
        ServiceModel(
            id: service.id,
            name: service.name,
            description: service.description ?? "",
            photoURLs: service.imageUrls.compactMap(URL.init(string:)),
            price: Localization.salonPriceFrom(formattedPrice(service.price)),
            duration: Localization.salonDuration("\(service.durationMinutes)"),
            isAdded: false
        )
    }

    func specialistRowModel(for worker: SalonWorker) -> SpecialistModel {
        let slots = workerSlots[worker.id] ?? []
        return SpecialistModel(
            id: worker.id,
            name: "\(worker.firstName) \(worker.lastName)".trimmingCharacters(in: .whitespaces),
            specialty: worker.position ?? "",
            imageURL: worker.photoUrl.flatMap(URL.init(string:)),
            availableTimeSlots: slots.map(\.time),
            nearestDate: nearestDateLabel(for: slots)
        )
    }

    // A fresh binding per render into the per-worker selection dictionary, so the
    // tapped slot pill highlights and its datetime can be carried forward.
    func selectedSlotBinding(for workerId: String) -> Binding<String?> {
        Binding(
            get: { self.selectedSlotByWorker[workerId] },
            set: { self.selectedSlotByWorker[workerId] = $0 }
        )
    }

    // MARK: - Intents

    func didTapBack() {
        transition.didTapBack()
    }

    func didTapBook() {
        // Booking requires a signed-in user regardless of provider.
        guard requireAuth() else { return }
        switch salon?.provider {
        case .easyweek:
            // Booking itself happens in the EasyWeek web widget.
            if let url = salon?.bookingUrl {
                openWebView(url: url, title: salon?.name)
            } else {
                showComingSoon()
            }
        case .altegio:
            // In-app booking — start service selection with nothing preselected.
            if let salon { transition.didRequestBooking(salon, .book, availableServiceIds ?? []) }
        default:
            // Unknown / nil providers.
            showComingSoon()
        }
    }

    // Per-row "Add" (service) / "Обрати" (specialist) actions are only shown for
    // the in-app (Altegio) flow, which requires a signed-in user.
    func didTapAddService(_ service: SalonService) {
        guard requireAuth() else { return }
        guard let salon, salon.provider == .altegio else {
            showComingSoon()
            return
        }
        // Open service selection with this service preselected + its category active.
        transition.didRequestBooking(salon, .service(id: service.id), availableServiceIds ?? [])
    }

    func didTapSelectSpecialist(_ worker: SalonWorker) {
        guard requireAuth() else { return }
        guard let salon, salon.provider == .altegio else {
            showComingSoon()
            return
        }
        // Open service selection, remembering the chosen specialist and slot
        // datetime so the next step can filter services by that datetime too.
        let datetime = selectedSlotDatetime(for: worker.id)
        transition.didRequestBooking(salon, .worker(id: worker.id, datetime: datetime), availableServiceIds ?? [])
    }

    // "Будь-який" — book without choosing a specialist (no worker/datetime filter).
    func didTapSelectAnySpecialist() {
        guard requireAuth() else { return }
        guard let salon, salon.provider == .altegio else {
            showComingSoon()
            return
        }
        transition.didRequestBooking(salon, .book, availableServiceIds ?? [])
    }

    private func showComingSoon() {
        showSuccess(
            title: Localization.salonProfileComingSoonTitle,
            message: Localization.salonProfileComingSoonMessage,
            scope: .current
        )
    }

    func didTapShare() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let share = try await self.getSalonShareUseCase.execute(id: self.salonId)
                self.shareSheet = ShareSheetPresentation(url: share.url, title: share.title)
            } catch {
                self.showError(error)
            }
        }
    }

    func didTapFavorite() {
        guard requireAuth() else { return }
        let wasFavorited = isFavorited
        isFavorited = !wasFavorited
        Task { [weak self] in
            guard let self else { return }
            do {
                if wasFavorited {
                    try await self.unsaveSalonUseCase.execute(salonId: self.salonId)
                } else {
                    try await self.saveSalonUseCase.execute(salonId: self.salonId)
                }
            } catch {
                self.isFavorited = wasFavorited
                self.showError(error)
            }
        }
    }

    // MARK: - Private

    // Returns true when a user is signed in; otherwise kicks off the auth flow
    // and returns false so the caller can bail out.
    private func requireAuth() -> Bool {
        guard sessionManager.isAuthenticated else {
            transition.didRequireAuth()
            return false
        }
        return true
    }

    private func loadSalon() async {
        showLoader()
        do {
            let result = try await getSalonByIdUseCase.execute(id: salonId)
            salon = result
            isFavorited = result.isSaved
            hideLoader()
            // Altegio salons additionally resolve which services and workers are
            // bookable. Loaded after the profile is shown (the CRM calls can be
            // slow), with each tab showing its own loader meanwhile.
            if result.provider == .altegio {
                await loadAvailability()
                await loadWorkers()
            }
        } catch {
            hideLoader()
            showError(error)
        }
    }

    private func loadAvailability() async {
        isLoadingAvailability = true
        defer { isLoadingAvailability = false }
        do {
            availableServiceIds = try await getAltegioAvailableServicesUseCase.execute(
                salonId: salonId,
                selectedServiceIds: [],
                workerId: nil
            )
        } catch {
            showError(error)
        }
    }

    // Resolves bookable workers + their next slots. No filters here — the user
    // hasn't picked services/time yet on the profile; `includeSlots` powers the
    // nearest-date label and slot pills.
    private func loadWorkers() async {
        isLoadingWorkers = true
        defer { isLoadingWorkers = false }
        do {
            let workers = try await getAltegioAvailableWorkersUseCase.execute(
                salonId: salonId,
                serviceIds: [],
                datetime: nil,
                includeSlots: true
            )
            availableWorkerIds = Set(workers.filter { $0.isBookable }.map { $0.id })
            var slotsById: [String: [AltegioBookingSlot]] = [:]
            var defaultSelection: [String: String] = [:]
            for worker in workers where worker.isBookable {
                slotsById[worker.id] = worker.slots
                // Pre-select the nearest slot, matching the Figma highlight.
                if let nearest = worker.slots.first {
                    defaultSelection[worker.id] = nearest.time
                }
            }
            workerSlots = slotsById
            selectedSlotByWorker = defaultSelection
        } catch {
            showError(error)
        }
    }

    // Datetime of the worker's currently-selected slot (the nearest by default),
    // carried into the booking flow. `nil` when the worker has no slots.
    private func selectedSlotDatetime(for workerId: String) -> String? {
        let slots = workerSlots[workerId] ?? []
        if let time = selectedSlotByWorker[workerId],
           let slot = slots.first(where: { $0.time == time }) {
            return slot.datetime
        }
        return slots.first?.datetime
    }

    private func nearestDateLabel(for slots: [AltegioBookingSlot]) -> String? {
        guard let date = slots.first?.date else { return nil }
        return Localization.salonSpecialistNearestDate(Self.nearestDateFormatter.string(from: date))
    }

    private static let nearestDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "dd.MM"
        return formatter
    }()

    private func observeSavedSalonsBus() {
        savedSalonsEventBus.changes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] change in
                guard let self else { return }
                guard change.salonId == self.salonId else { return }
                self.isFavorited = change.isSaved
            }
            .store(in: &cancellables)
    }

    private func formattedPrice(_ price: Double) -> String {
        price.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", price)
            : String(format: "%.2f", price)
    }
}
