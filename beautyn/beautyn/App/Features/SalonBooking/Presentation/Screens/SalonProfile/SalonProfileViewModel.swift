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

    // MARK: - Dependencies

    private let salonId: String
    private let transition: Transition
    private let getSalonByIdUseCase: any GetSalonByIdUseCase
    private let getSalonShareUseCase: any GetSalonShareUseCase
    private let getAltegioAvailableServicesUseCase: any GetAltegioAvailableServicesUseCase
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
        guard let workers = salon?.workers else { return [] }
        let q = specialistsSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return workers }
        return workers.filter { worker in
            let fullName = "\(worker.firstName) \(worker.lastName)"
            return fullName.localizedCaseInsensitiveContains(q)
                || (worker.position?.localizedCaseInsensitiveContains(q) ?? false)
        }
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
        SpecialistModel(
            id: worker.id,
            name: "\(worker.firstName) \(worker.lastName)".trimmingCharacters(in: .whitespaces),
            specialty: worker.position ?? "",
            imageURL: worker.photoUrl.flatMap(URL.init(string:)),
            availableTimeSlots: [],
            nearestDate: nil
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
        // Open service selection, remembering the chosen specialist for later steps.
        transition.didRequestBooking(salon, .worker(id: worker.id), availableServiceIds ?? [])
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
            // Altegio salons additionally resolve which services are bookable.
            // Loaded after the profile is shown (the CRM call can be slow), with
            // the Services tab showing its own loader meanwhile.
            if result.provider == .altegio {
                await loadAvailability()
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
