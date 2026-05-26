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
        let didRequestBooking: (_ salonId: String) -> Void
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
    @Published var searchQuery: String = ""
    @Published private(set) var isFavorited: Bool = false
    @Published var shareSheet: ShareSheetPresentation?

    // MARK: - Dependencies

    private let salonId: String
    private let transition: Transition
    private let getSalonByIdUseCase: any GetSalonByIdUseCase
    private let getSalonShareUseCase: any GetSalonShareUseCase
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
        saveSalonUseCase: any SaveSalonUseCase,
        unsaveSalonUseCase: any UnsaveSalonUseCase,
        savedSalonsEventBus: any SavedSalonsEventBus,
        sessionManager: SessionManager
    ) {
        self.salonId = salonId
        self.transition = transition
        self.getSalonByIdUseCase = getSalonByIdUseCase
        self.getSalonShareUseCase = getSalonShareUseCase
        self.saveSalonUseCase = saveSalonUseCase
        self.unsaveSalonUseCase = unsaveSalonUseCase
        self.savedSalonsEventBus = savedSalonsEventBus
        self.sessionManager = sessionManager
        super.init()
        observeSavedSalonsBus()
    }

    // MARK: - Lifecycle

    override func onViewTask() async {
        await loadSalon()
    }

    // MARK: - Computed

    var filteredServices: [SalonService] {
        guard let services = salon?.services else { return [] }
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return services }
        return services.filter { service in
            service.name.localizedCaseInsensitiveContains(q)
                || (service.description?.localizedCaseInsensitiveContains(q) ?? false)
        }
    }

    var filteredWorkers: [SalonWorker] {
        guard let workers = salon?.workers else { return [] }
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return workers }
        return workers.filter { worker in
            let fullName = "\(worker.firstName) \(worker.lastName)"
            return fullName.localizedCaseInsensitiveContains(q)
                || (worker.position?.localizedCaseInsensitiveContains(q) ?? false)
        }
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
        guard sessionManager.isAuthenticated else {
            transition.didRequireAuth()
            return
        }
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

    private func loadSalon() async {
        showLoader()
        defer { hideLoader() }
        do {
            let result = try await getSalonByIdUseCase.execute(id: salonId)
            salon = result
            isFavorited = result.isSaved
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
