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
        let didTapAppointmentDetails: (_ booking: Booking) -> Void
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
    /// Raw next booking, retained so the details screen can be opened with the
    /// full model (the card only carries the formatted presentation values).
    private var nextBooking: NextBooking?
    @Published private(set) var savedSalons: [SavedSalonUI] = []
    @Published private(set) var sections: [SectionUI] = []

    // MARK: - Dependencies

    private let transition: Transition
    private let getHomeFeedUseCase: GetHomeFeedUseCase
    private let saveSalonUseCase: any SaveSalonUseCase
    private let unsaveSalonUseCase: any UnsaveSalonUseCase
    private let savedSalonsEventBus: any SavedSalonsEventBus
    private let bookingEventBus: any BookingEventBus
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
        bookingEventBus: any BookingEventBus,
        sessionManager: SessionManager,
        getCurrentUserUseCase: any GetCurrentUserUseCase
    ) {
        self.transition = transition
        self.getHomeFeedUseCase = getHomeFeedUseCase
        self.saveSalonUseCase = saveSalonUseCase
        self.unsaveSalonUseCase = unsaveSalonUseCase
        self.savedSalonsEventBus = savedSalonsEventBus
        self.bookingEventBus = bookingEventBus
        self.sessionManager = sessionManager
        self.getCurrentUserUseCase = getCurrentUserUseCase
        super.init()
        observeAuthState()
        observeSavedSalonsBus()
        observeBookingCreated()
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

    private func observeBookingCreated() {
        bookingEventBus.bookingCreated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Silent reload (no full-screen loader) so the next-appointment
                // card is already fresh when the user returns to Home.
                Task { [weak self] in
                    await self?.fetchFeed()
                }
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

        // Animate just the saved-list mutation so the row (and the feed below it)
        // slides instead of jumping. The section heart toggle above stays instant.
        if change.isSaved {
            if !savedSalons.contains(where: { $0.id == change.salonId }),
               let card = sections.lazy.flatMap(\.items).first(where: { $0.id == change.salonId }) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    savedSalons.insert(
                        SavedSalonUI(id: card.id, salonName: card.name, imageURL: card.imageURL),
                        at: 0
                    )
                }
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                savedSalons.removeAll { $0.id == change.salonId }
            }
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
        guard let nextBooking else { return }
        transition.didTapAppointmentDetails(NextBookingMapper.makeBooking(nextBooking))
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
            nextBooking = booking
            nextAppointment = mapBookingToAppointment(booking)
        } else {
            nextBooking = nil
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
            // Same presentation as the My Bookings upcoming card — relative
            // "Сьогодні" / "Завтра" day and shared time format — only the map is
            // omitted (no coordinate), per design.
            date: AppointmentDateFormatter.dateString(booking.datetime, relativeDay: true, timeZone: booking.timezone),
            time: AppointmentDateFormatter.timeString(start: booking.datetime, end: booking.endDatetime, timeZone: booking.timezone),
            price: price,
            duration: duration,
            serviceName: booking.serviceNames.isEmpty ? nil : booking.serviceNames.joined(separator: ", ")
        )
    }
}
