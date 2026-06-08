import Combine
import Foundation
import SwiftUI

// MARK: - HomeViewModel

@MainActor
final class HomeViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        let didTapSearch: () -> Void
        let didTapSalonCard: (_ salonId: String) -> Void
        let didTapSavedSalon: (_ salonId: String) -> Void
        let didTapSeeAllSaved: () -> Void
        let didTapSeeAllSection: (_ sectionId: String) -> Void
        let didTapAppointmentDetails: (_ bookingId: String) -> Void
        let didTapCategory: (_ categoryId: String) -> Void
        let didRequireAuth: () -> Void
    }

    // MARK: - Section UI Model

    struct SectionUI: Identifiable {
        let id: String
        let title: String
        let items: [SalonCardModel]
    }

    // MARK: - Published State

    @Published private(set) var greeting: String = Localization.homeGreetingUnauthorized
    @Published private(set) var categories: [CategoryChipModel] = []
    @Published private(set) var nextAppointment: AppointmentCardModel?
    @Published private(set) var savedSalons: [SavedSalonUI] = []
    @Published private(set) var sections: [SectionUI] = []

    // MARK: - Dependencies

    private let transition: Transition
    private let getHomeFeedUseCase: GetHomeFeedUseCase
    private let saveSalonUseCase: any SaveSalonUseCase
    private let unsaveSalonUseCase: any UnsaveSalonUseCase
    private let savedSalonsEventBus: any SavedSalonsEventBus
    private let sessionManager: SessionManager
    private let getCurrentUserUseCase: any GetCurrentUserUseCase
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        transition: Transition,
        getHomeFeedUseCase: GetHomeFeedUseCase,
        saveSalonUseCase: any SaveSalonUseCase,
        unsaveSalonUseCase: any UnsaveSalonUseCase,
        savedSalonsEventBus: any SavedSalonsEventBus,
        sessionManager: SessionManager,
        getCurrentUserUseCase: any GetCurrentUserUseCase
    ) {
        self.transition = transition
        self.getHomeFeedUseCase = getHomeFeedUseCase
        self.saveSalonUseCase = saveSalonUseCase
        self.unsaveSalonUseCase = unsaveSalonUseCase
        self.savedSalonsEventBus = savedSalonsEventBus
        self.sessionManager = sessionManager
        self.getCurrentUserUseCase = getCurrentUserUseCase
        super.init()
        observeAuthState()
        observeSavedSalonsBus()
        Task { [weak self] in
            await self?.loadHomeFeed()
        }
    }

    // MARK: - Lifecycle

    private func observeAuthState() {
        sessionManager.isAuthenticatedPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.loadHomeFeed()
                }
            }
            .store(in: &cancellables)
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
        sections = sections.map { section in
            SectionUI(
                id: section.id,
                title: section.title,
                items: section.items.map { item in
                    guard item.id == change.salonId, item.isFavorited != change.isSaved else { return item }
                    var updated = item
                    updated.isFavorited = change.isSaved
                    return updated
                }
            )
        }

        if change.isSaved {
            if !savedSalons.contains(where: { $0.id == change.salonId }),
               let card = sections.lazy.flatMap(\.items).first(where: { $0.id == change.salonId }) {
                savedSalons.insert(
                    SavedSalonUI(id: card.id, salonName: card.name, imageURL: card.imageURL),
                    at: 0
                )
            }
        } else {
            savedSalons.removeAll { $0.id == change.salonId }
        }
    }

    // MARK: - Intents

    func didTapSearch() {
        transition.didTapSearch()
    }

    func didTapCategory(_ category: CategoryChipModel) {
        transition.didTapCategory(category.id)
    }

    func didTapSalonCard(_ salonId: String) {
        transition.didTapSalonCard(salonId)
    }

    func didTapSavedSalon(_ salon: SavedSalonUI) {
        transition.didTapSavedSalon(salon.id)
    }

    func didTapSeeAllSaved() {
        transition.didTapSeeAllSaved()
    }

    func didTapSeeAllSection(_ sectionId: String) {
        transition.didTapSeeAllSection(sectionId)
    }

    func didTapAppointmentDetails() {
        guard let booking = nextAppointment else { return }
        transition.didTapAppointmentDetails(booking.id)
    }

    func didTapFavorite(salonId: String) {
        guard sessionManager.isAuthenticated else {
            transition.didRequireAuth()
            return
        }
        guard let location = locateCard(salonId: salonId) else { return }
        let wasFavorited = sections[location.section].items[location.item].isFavorited
        setFavorited(!wasFavorited, at: location)

        Task { [weak self] in
            guard let self else { return }
            do {
                if wasFavorited {
                    try await self.unsaveSalonUseCase.execute(salonId: salonId)
                } else {
                    try await self.saveSalonUseCase.execute(salonId: salonId)
                }
            } catch {
                if let revertLocation = self.locateCard(salonId: salonId) {
                    self.setFavorited(wasFavorited, at: revertLocation)
                }
                self.showError(error)
            }
        }
    }

    private func locateCard(salonId: String) -> (section: Int, item: Int)? {
        for (sectionIndex, section) in sections.enumerated() {
            if let itemIndex = section.items.firstIndex(where: { $0.id == salonId }) {
                return (sectionIndex, itemIndex)
            }
        }
        return nil
    }

    private func setFavorited(_ isFavorited: Bool, at location: (section: Int, item: Int)) {
        var sectionsCopy = sections
        var items = sectionsCopy[location.section].items
        items[location.item].isFavorited = isFavorited
        let original = sectionsCopy[location.section]
        sectionsCopy[location.section] = SectionUI(id: original.id, title: original.title, items: items)
        sections = sectionsCopy
    }

    // MARK: - Testing Support

    #if DEBUG
    func applyMockFeed(_ feed: HomeFeed) {
        mapFeedToState(feed)
    }
    #endif

    // MARK: - Private

    private func loadHomeFeed() async {
        showLoader()
        defer { hideLoader() }
        await fetchFeed()
    }

    // Pull-to-refresh: reuses the feed fetch but relies on the system refresh
    // control's own spinner instead of the full-screen loader.
    func refresh() async {
        await fetchFeed()
    }

    private func fetchFeed() async {
        do {
            let feed = try await getHomeFeedUseCase.execute(latitude: nil, longitude: nil)
            mapFeedToState(feed)
            await loadGreeting()
        } catch {
            showError(error)
        }
    }

    private func loadGreeting() async {
        guard sessionManager.isAuthenticated else {
            greeting = Localization.homeGreetingUnauthorized
            return
        }
        let name = try? await getCurrentUserUseCase.execute().name
        if let name, !name.isEmpty {
            greeting = Localization.homeGreeting(name)
        } else {
            greeting = Localization.homeGreetingUnauthorized
        }
    }

    private func mapFeedToState(_ feed: HomeFeed) {
        // Categories (unauthorized only — when categories are present)
        categories = feed.categories.sorted(by: { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) }).map { cat in
            CategoryChipModel(
                id: cat.id,
                title: cat.name,
                imageURL: cat.imageUrl.flatMap(URL.init(string:))
            )
        }

        // Next appointment (auth only)
        if let booking = feed.nextBooking {
            nextAppointment = mapBookingToAppointment(booking)
        } else {
            nextAppointment = nil
        }

        // Saved salons (auth only)
        savedSalons = feed.savedSalons?.map { saved in
            SavedSalonUI(
                id: saved.salonId,
                salonName: saved.salonName,
                imageURL: saved.coverImageUrl.flatMap(URL.init(string:))
            )
        } ?? []

        // Dynamic sections
        sections = feed.sections.map { section in
            let titleWithEmoji = [section.title, section.emoji].compactMap { $0 }.joined(separator: " ")
            return SectionUI(
                id: section.id,
                title: titleWithEmoji,
                items: section.items.map { card in
                    SalonCardModel(
                        id: card.id,
                        name: card.name,
                        address: card.addressLine ?? "",
                        imageURL: card.coverImageUrl.flatMap(URL.init(string:)),
                        rating: card.ratingAvg,
                        tag: nil,
                        isFavorited: card.isSaved
                    )
                }
            )
        }
    }

    private func mapBookingToAppointment(_ booking: NextBooking) -> AppointmentCardModel {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .appDisplay
        dateFormatter.dateFormat = "EEEE, d MMM, yyyy"
        let dateString = dateFormatter.string(from: booking.datetime).capitalized

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "H:mm"
        var timeString = timeFormatter.string(from: booking.datetime)
        if let end = booking.endDatetime {
            timeString += " - " + timeFormatter.string(from: end)
        }

        let price: String
        if let cents = booking.totalPriceCents {
            price = Localization.homeAppointmentPrice("\(cents / 100)")
        } else {
            price = ""
        }

        let duration: String
        if let minutes = booking.durationMinutes {
            duration = Localization.homeAppointmentDuration("\(minutes)")
        } else {
            duration = ""
        }

        return AppointmentCardModel(
            id: booking.bookingId,
            salonName: booking.salonName,
            address: booking.salonAddressLine ?? "",
            salonImageURL: booking.salonCoverImageUrl.flatMap(URL.init(string:)),
            date: dateString,
            time: timeString,
            price: price,
            duration: duration
        )
    }
}
