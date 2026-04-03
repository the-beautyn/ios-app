import SwiftUI
import XCTest
@testable import beautyn

// MARK: - HomeViewRenderTests
//
// Renders the actual HomeView with mock data to PNG files for visual verification.
// The mock use case returns preview data, which flows through the normal
// ViewModel lifecycle (onViewTask → loadHomeFeed → mapFeedToState).
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
//     -only-testing:beautynTests/HomeViewRenderTests

@MainActor
final class HomeViewRenderTests: XCTestCase {

    // MARK: - Unauthorized State

    func testRenderHomeUnauthorized() async throws {
        let view = HomeView(
            viewModel: self.makeViewModel(feed: .unauthorizedPreview)
        )
        try await ViewRenderer.render(view, name: "home_unauthorized")
    }

    // MARK: - Authorized State

    func testRenderHomeAuthorized() async throws {
        let view = HomeView(
            viewModel: self.makeViewModel(feed: .authorizedPreview)
        )
        try await ViewRenderer.render(view, name: "home_authorized")
    }

    // MARK: - Helpers

    private func makeViewModel(feed: HomeFeed) -> HomeViewModel {
        HomeViewModel(
            transition: .init(
                didTapSearch: {},
                didTapSalonCard: { _ in },
                didTapSavedSalon: { _ in },
                didTapSeeAllSaved: {},
                didTapSeeAllSection: { _ in },
                didTapAppointmentDetails: { _ in },
                didTapCategory: { _ in }
            ),
            getHomeFeedUseCase: MockHomeFeedUseCase(feed: feed)
        )
    }
}

// MARK: - MockHomeFeedUseCase

private final class MockHomeFeedUseCase: GetHomeFeedUseCase {
    let feed: HomeFeed
    init(feed: HomeFeed) { self.feed = feed }

    func execute(latitude: Double?, longitude: Double?) async throws -> HomeFeed {
        feed
    }
}

// MARK: - Preview Data

extension HomeFeed {

    static let unauthorizedPreview = HomeFeed(
        categories: [
            AppCategory(id: "1", slug: "nails", name: "Нігті", imageUrl: nil, sortOrder: 0),
            AppCategory(id: "2", slug: "hair", name: "Волосся", imageUrl: nil, sortOrder: 1),
            AppCategory(id: "3", slug: "spa", name: "SPA/Масаж", imageUrl: nil, sortOrder: 2),
            AppCategory(id: "4", slug: "injections", name: "Ін'єкції", imageUrl: nil, sortOrder: 3),
            AppCategory(id: "5", slug: "epilation", name: "Епіляція", imageUrl: nil, sortOrder: 4),
        ],
        nextBooking: nil,
        savedSalons: nil,
        sections: previewSections
    )

    static let authorizedPreview = HomeFeed(
        categories: nil,
        nextBooking: NextBooking(
            bookingId: "b1",
            salonId: "s1",
            salonName: "Nail bar: Glossy Room",
            salonCoverImageUrl: nil,
            salonAddressLine: "вул. Зеленицька, 15, 05-091",
            datetime: Date().addingTimeInterval(86400),
            endDatetime: Date().addingTimeInterval(86400 + 7200),
            totalPriceCents: 70000,
            durationMinutes: 90
        ),
        savedSalons: [
            SavedSalon(id: "ss1", salonId: "s1", salonName: "Nail bar: Glossy Room", coverImageUrl: nil, addressLine: nil, city: nil, ratingAvg: 4.5, ratingCount: 120, savedAt: Date()),
            SavedSalon(id: "ss2", salonId: "s2", salonName: "Beauty Studio", coverImageUrl: nil, addressLine: nil, city: nil, ratingAvg: 4.8, ratingCount: 85, savedAt: Date()),
            SavedSalon(id: "ss3", salonId: "s3", salonName: "Glamour Nails", coverImageUrl: nil, addressLine: nil, city: nil, ratingAvg: 4.2, ratingCount: 60, savedAt: Date()),
        ],
        sections: previewSections
    )

    private static let previewSections: [HomeFeedSection] = [
        HomeFeedSection(
            id: "sec1", type: "popular",
            title: "Популярні", emoji: "⭐️",
            items: previewSalonCards
        ),
        HomeFeedSection(
            id: "sec2", type: "category",
            title: "Nails доступні сьогодні", emoji: "💅🏼",
            items: previewSalonCards
        ),
        HomeFeedSection(
            id: "sec3", type: "nearMe",
            title: "Перукар біля тебе", emoji: "💇🏻‍♀️",
            items: previewSalonCards
        ),
    ]

    private static let previewSalonCards: [SalonCard] = [
        SalonCard(id: "c1", name: "Nail bar: Glossy Room", coverImageUrl: nil, addressLine: "вул. Зеленицька, 15 (411), 05-091", city: nil, ratingAvg: 4.5, ratingCount: 120, distanceKm: nil, isSaved: false),
        SalonCard(id: "c2", name: "Beauty Studio Kyiv", coverImageUrl: nil, addressLine: "вул. Франка, 10", city: nil, ratingAvg: 4.8, ratingCount: 85, distanceKm: nil, isSaved: true),
    ]
}
