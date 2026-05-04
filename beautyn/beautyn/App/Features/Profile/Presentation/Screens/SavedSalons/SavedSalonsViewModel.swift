import Combine
import Foundation

// MARK: - SavedSalonsViewModel

@MainActor
final class SavedSalonsViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        let didTapSalon: (_ salonId: String) -> Void
        let didTapBack: () -> Void
    }

    // MARK: - Published State

    @Published private(set) var allItems: [SalonCardModel] = []
    @Published var searchText: String = ""

    var items: [SalonCardModel] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return allItems }
        let needle = trimmed.lowercased()
        return allItems.filter { $0.name.lowercased().contains(needle) }
    }

    // MARK: - Dependencies

    private let transition: Transition
    private let getSavedSalonsUseCase: any GetSavedSalonsUseCase
    private let saveSalonUseCase: any SaveSalonUseCase
    private let unsaveSalonUseCase: any UnsaveSalonUseCase
    private let savedSalonsEventBus: any SavedSalonsEventBus
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        transition: Transition,
        getSavedSalonsUseCase: any GetSavedSalonsUseCase,
        saveSalonUseCase: any SaveSalonUseCase,
        unsaveSalonUseCase: any UnsaveSalonUseCase,
        savedSalonsEventBus: any SavedSalonsEventBus
    ) {
        self.transition = transition
        self.getSavedSalonsUseCase = getSavedSalonsUseCase
        self.saveSalonUseCase = saveSalonUseCase
        self.unsaveSalonUseCase = unsaveSalonUseCase
        self.savedSalonsEventBus = savedSalonsEventBus
        super.init()
        observeSavedSalonsBus()
    }

    // MARK: - Lifecycle

    override func onViewTask() async {
        await loadSalons()
    }

    // MARK: - Intents

    func didTapBack() { transition.didTapBack() }

    func didTapSalon(salonId: String) {
        transition.didTapSalon(salonId)
    }

    func didTapFavorite(salonId: String) {
        guard let index = allItems.firstIndex(where: { $0.id == salonId }) else { return }
        let wasFavorited = allItems[index].isFavorited
        allItems[index].isFavorited = !wasFavorited

        Task { [weak self] in
            guard let self else { return }
            do {
                if wasFavorited {
                    try await self.unsaveSalonUseCase.execute(salonId: salonId)
                } else {
                    try await self.saveSalonUseCase.execute(salonId: salonId)
                }
            } catch {
                if let revertIndex = self.allItems.firstIndex(where: { $0.id == salonId }) {
                    self.allItems[revertIndex].isFavorited = wasFavorited
                }
                self.showError(error)
            }
        }
    }

    // MARK: - Private

    private func loadSalons() async {
        showLoader()
        defer { hideLoader() }

        do {
            let list = try await getSavedSalonsUseCase.execute(query: nil, page: nil, limit: nil)
            allItems = list.items.map(Self.mapToCard)
        } catch {
            showError(error)
        }
    }

    private func observeSavedSalonsBus() {
        savedSalonsEventBus.changes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] change in
                self?.applySavedChange(change)
            }
            .store(in: &cancellables)
    }

    private func applySavedChange(_ change: SavedSalonChange) {
        allItems = allItems.map { item in
            guard item.id == change.salonId, item.isFavorited != change.isSaved else { return item }
            var updated = item
            updated.isFavorited = change.isSaved
            return updated
        }
    }

    private static func mapToCard(_ salon: SavedSalon) -> SalonCardModel {
        SalonCardModel(
            id: salon.salonId,
            name: salon.salonName,
            address: salon.addressLine ?? "",
            imageURL: salon.coverImageUrl.flatMap(URL.init(string:)),
            rating: salon.ratingAvg,
            tag: nil,
            isFavorited: true
        )
    }
}
