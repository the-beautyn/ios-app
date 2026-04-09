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
    private let sessionManager: SessionManager
    private let userRepository: UserRepository
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(transition: Transition, getHomeFeedUseCase: GetHomeFeedUseCase, sessionManager: SessionManager, userRepository: UserRepository) {
        self.transition = transition
        self.getHomeFeedUseCase = getHomeFeedUseCase
        self.sessionManager = sessionManager
        self.userRepository = userRepository
        super.init()
    }

    // MARK: - Lifecycle

    override func onViewTask() async {
        await loadHomeFeed()
        observeAuthState()
    }

    private func observeAuthState() {
        sessionManager.$authState
            .dropFirst()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.loadHomeFeed()
                }
            }
            .store(in: &cancellables)
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
        // TODO: Implement favorite toggle via use case
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

        do {
            let feed = try await getHomeFeedUseCase.execute(latitude: nil, longitude: nil)
            mapFeedToState(feed)
        } catch {
            showError(error)
        }
    }

    private func mapFeedToState(_ feed: HomeFeed) {
        if let name = userRepository.getCachedProfile()?.name, !name.isEmpty {
            greeting = Localization.homeGreeting(name)
        } else {
            greeting = Localization.homeGreetingUnauthorized
        }

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
        dateFormatter.locale = Locale(identifier: "uk_UA")
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
