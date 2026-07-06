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
        /// Switches to the Search tab and searches with this category applied.
        let didTapCategory: (_ category: AppCategory) -> Void
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
    /// The feed's domain categories behind the header chips — kept so a tap
    /// can hand the full model (not just the id) to the Search tab.
    private var feedCategories: [AppCategory] = []
    @Published private(set) var nextAppointment: AppointmentCardModel?
    /// The booking currently shown on the card (feed snapshot, overlaid by the
    /// source-of-truth copy when cached), retained so the details screen can open.
    private var nextBooking: Booking?
    private var nextBookingCancellable: AnyCancellable?
    @Published private(set) var savedSalons: [SavedSalonUI] = []
    @Published private(set) var sections: [SectionUI] = []

    // MARK: - Dependencies

    private let transition: Transition
    private let getHomeFeedUseCase: GetHomeFeedUseCase
    private let saveSalonUseCase: any SaveSalonUseCase
    private let unsaveSalonUseCase: any UnsaveSalonUseCase
    private let savedSalonsEventBus: any SavedSalonsEventBus
    private let observeBookingUseCase: any ObserveBookingUseCase
    private let sessionManager: SessionManager
    private let getCurrentUserUseCase: any GetCurrentUserUseCase
    private var cancellables = Set<AnyCancellable>()

    // Appear-driven loading: the first appearance shows the full-screen loader;
    // every later appearance refreshes silently and animates any feed changes.
    private var hasLoadedOnce = false
    private var isFetching = false

    // MARK: - Init

    init(
        transition: Transition,
        getHomeFeedUseCase: GetHomeFeedUseCase,
        saveSalonUseCase: any SaveSalonUseCase,
        unsaveSalonUseCase: any UnsaveSalonUseCase,
        savedSalonsEventBus: any SavedSalonsEventBus,
        observeBookingUseCase: any ObserveBookingUseCase,
        sessionManager: SessionManager,
        getCurrentUserUseCase: any GetCurrentUserUseCase
    ) {
        self.transition = transition
        self.getHomeFeedUseCase = getHomeFeedUseCase
        self.saveSalonUseCase = saveSalonUseCase
        self.unsaveSalonUseCase = unsaveSalonUseCase
        self.savedSalonsEventBus = savedSalonsEventBus
        self.observeBookingUseCase = observeBookingUseCase
        self.sessionManager = sessionManager
        self.getCurrentUserUseCase = getCurrentUserUseCase
        super.init()
        observeAuthState()
        observeSavedSalonsBus()
    }

    // MARK: - Lifecycle

    // Loads on first appearance (with the loader) and silently refreshes on every
    // subsequent appearance — returning from a salon, a tab switch, etc. — so the
    // feed reflects new saves / bookings / sections without a visible reload.
    override func onViewTask() async {
        await refreshOnAppear()
    }

    private func refreshOnAppear() async {
        guard !isFetching else { return }
        isFetching = true
        defer { isFetching = false }

        if hasLoadedOnce {
            await fetchFeed(animated: true)
        } else {
            await loadHomeFeed()
            hasLoadedOnce = true
        }
    }

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
        guard let appCategory = feedCategories.first(where: { $0.id == category.id }) else { return }
        transition.didTapCategory(appCategory)
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
        transition.didTapAppointmentDetails(nextBooking)
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
        mapFeedToState(feed, animated: false)
    }
    #endif

    // MARK: - Private

    private func loadHomeFeed() async {
        showLoader()
        defer { hideLoader() }
        await fetchFeed(animated: false)
    }

    // Pull-to-refresh: reuses the feed fetch but relies on the system refresh
    // control's own spinner instead of the full-screen loader, and animates any
    // sections/rows that changed.
    func refresh() async {
        await fetchFeed(animated: true)
    }

    private func fetchFeed(animated: Bool) async {
        do {
            let feed = try await getHomeFeedUseCase.execute(latitude: nil, longitude: nil)
            mapFeedToState(feed, animated: animated)
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

    private func mapFeedToState(_ feed: HomeFeed, animated: Bool) {
        // Categories live in the pinned header — assigned without animation; the
        // scrollable feed below is what animates on a silent refresh.
        feedCategories = feed.categories.sorted(by: { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) })
        categories = feedCategories.map { cat in
            CategoryChipModel(
                id: cat.id,
                title: cat.name,
                imageURL: cat.imageUrl.flatMap(URL.init(string:))
            )
        }

        let newSavedSalons = feed.savedSalons?.map { saved in
            SavedSalonUI(
                id: saved.salonId,
                salonName: saved.salonName,
                imageURL: saved.coverImageUrl.flatMap(URL.init(string:))
            )
        } ?? []

        let newSections = feed.sections.map { section in
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

        // Next appointment (auth only). Render from the feed snapshot, then observe
        // the bookings source of truth by id so a change made elsewhere (e.g. a
        // cancel) reflects here without re-fetching the whole feed.
        let newBooking = feed.nextBooking.map(NextBookingMapper.makeBooking)

        // On a silent refresh, animate the section/row diffs (paired with the
        // .transition styles in HomeView); on the first load, snap into place.
        if animated {
            withAnimation(.easeInOut(duration: 0.3)) {
                savedSalons = newSavedSalons
                sections = newSections
                observeNextBooking(newBooking)
            }
        } else {
            savedSalons = newSavedSalons
            sections = newSections
            observeNextBooking(newBooking)
        }
    }

    // MARK: - Next booking

    private func observeNextBooking(_ feedBooking: Booking?) {
        nextBookingCancellable = nil

        guard let feedBooking else {
            nextBooking = nil
            nextAppointment = nil
            return
        }

        // Show the feed snapshot immediately…
        applyNextBooking(feedBooking)
        // …then prefer the source-of-truth copy whenever it has one (keeps the
        // feed snapshot when the booking isn't cached).
        nextBookingCancellable = observeBookingUseCase.execute(id: feedBooking.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cached in
                self?.applyNextBooking(cached ?? feedBooking)
            }
    }

    private func applyNextBooking(_ booking: Booking) {
        nextBooking = booking
        // Hide the card once the appointment is cancelled / removed.
        guard booking.status != .canceled, booking.status != .deleted else {
            nextBooking = nil
            nextAppointment = nil
            return
        }
        nextAppointment = mapBookingToAppointment(booking)
    }

    private func mapBookingToAppointment(_ booking: Booking) -> AppointmentCardModel {
        let price: String
        if let total = booking.totalPrice {
            price = Localization.homeAppointmentPrice(Self.priceString(total))
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
            id: booking.id,
            salonName: booking.salonName,
            address: booking.salonAddress ?? "",
            salonImageURL: booking.salonImageURL,
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

    private static func priceString(_ price: Double) -> String {
        price.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", price)
            : String(format: "%.2f", price)
    }
}
