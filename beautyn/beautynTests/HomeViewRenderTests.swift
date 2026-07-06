import Combine
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
                didTapCategory: { _ in },
                didRequireAuth: {}
            ),
            getHomeFeedUseCase: MockHomeFeedUseCase(feed: feed),
            saveSalonUseCase: MockSaveSalonUseCase(),
            unsaveSalonUseCase: MockUnsaveSalonUseCase(),
            savedSalonsEventBus: MockSavedSalonsEventBus(),
            observeBookingUseCase: MockObserveBookingUseCase(),
            sessionManager: SessionManager(keychainService: KeychainServiceImpl(), defaultsService: DefaultsStorageService()),
            getCurrentUserUseCase: MockGetCurrentUserUseCase()
        )
    }
}

// MARK: - HomeSectionSearchPresetTests
//
// A section-header tap must resolve the section's backend-provided search
// params into a SectionSearchPreset (category id resolved to the feed's full
// AppCategory) and hand it to the transition.

@MainActor
final class HomeSectionSearchPresetTests: XCTestCase {

    /// Deallocating a @MainActor VM (Combine publishers) inside a sync test
    /// crashes the runner on Xcode 26 — keep them alive until suite teardown.
    private var retainedViewModels: [HomeViewModel] = []

    func testSeeAllSectionResolvesPreset() throws {
        var captured: SectionSearchPreset?
        let viewModel = makeViewModel { captured = $0 }

        let date = ApiDateFormatter.date(from: "2099-01-15")
        viewModel.applyMockFeed(makeFeed(sections: [
            HomeFeedSection(
                id: "sec1", type: "category",
                title: "Нігті сьогодні", emoji: "💅🏼",
                items: [],
                searchParams: HomeSectionSearchParams(
                    query: "манікюр",
                    appCategoryIds: ["1"],
                    sortBy: .popular,
                    priceMin: 100,
                    priceMax: 900,
                    date: date
                )
            )
        ]))

        viewModel.didTapSeeAllSection("sec1")

        let preset = try XCTUnwrap(captured)
        XCTAssertEqual(preset.query, "манікюр")
        XCTAssertEqual(preset.category?.id, "1")
        XCTAssertEqual(preset.category?.name, "Нігті")
        XCTAssertEqual(preset.sortBy, .popular)
        XCTAssertEqual(preset.priceMin, 100)
        XCTAssertEqual(preset.priceMax, 900)
        XCTAssertEqual(preset.date, date)
    }

    func testSeeAllSectionWithoutParamsSendsEmptyPreset() throws {
        var captured: SectionSearchPreset?
        let viewModel = makeViewModel { captured = $0 }

        viewModel.applyMockFeed(makeFeed(sections: [
            HomeFeedSection(id: "sec1", type: "popular", title: "Популярні", emoji: nil, items: [])
        ]))

        viewModel.didTapSeeAllSection("sec1")

        let preset = try XCTUnwrap(captured)
        XCTAssertNil(preset.query)
        XCTAssertNil(preset.category)
        XCTAssertNil(preset.sortBy)
        XCTAssertNil(preset.priceMin)
        XCTAssertNil(preset.priceMax)
        XCTAssertNil(preset.date)
    }

    func testSectionSearchParamsDecodingAndMapping() throws {
        let json = """
        {
            "categories": [],
            "sections": [{
                "id": "sec1",
                "type": "deals",
                "title": "Бюджетні",
                "emoji": "💰",
                "items": [],
                "search_params": {
                    "query": "стрижка",
                    "app_category_ids": ["cat2"],
                    "sort_by": "price_asc",
                    "price_min": 100,
                    "price_max": 500,
                    "date": "2099-01-15"
                }
            }]
        }
        """
        let dto = try JSONDecoder().decode(HomeFeedResponseDTO.self, from: Data(json.utf8))
        let feed = HomeFeedMapper.map(dto)

        let params = try XCTUnwrap(feed.sections.first?.searchParams)
        XCTAssertEqual(params.query, "стрижка")
        XCTAssertEqual(params.appCategoryIds, ["cat2"])
        XCTAssertEqual(params.sortBy, .priceAsc)
        XCTAssertEqual(params.priceMin, 100)
        XCTAssertEqual(params.priceMax, 500)
        XCTAssertEqual(params.date, ApiDateFormatter.date(from: "2099-01-15"))
    }

    // MARK: - Helpers

    private func makeFeed(sections: [HomeFeedSection]) -> HomeFeed {
        HomeFeed(
            categories: HomeFeed.unauthorizedPreview.categories,
            nextBooking: nil,
            savedSalons: nil,
            sections: sections
        )
    }

    private func makeViewModel(onSeeAllSection: @escaping (SectionSearchPreset) -> Void) -> HomeViewModel {
        let viewModel = HomeViewModel(
            transition: .init(
                didTapSearch: {},
                didTapSalonCard: { _ in },
                didTapSavedSalon: { _ in },
                didTapSeeAllSaved: {},
                didTapSeeAllSection: onSeeAllSection,
                didTapAppointmentDetails: { _ in },
                didTapCategory: { _ in },
                didRequireAuth: {}
            ),
            getHomeFeedUseCase: MockHomeFeedUseCase(feed: .unauthorizedPreview),
            saveSalonUseCase: MockSaveSalonUseCase(),
            unsaveSalonUseCase: MockUnsaveSalonUseCase(),
            savedSalonsEventBus: MockSavedSalonsEventBus(),
            observeBookingUseCase: MockObserveBookingUseCase(),
            sessionManager: SessionManager(keychainService: KeychainServiceImpl(), defaultsService: DefaultsStorageService()),
            getCurrentUserUseCase: MockGetCurrentUserUseCase()
        )
        retainedViewModels.append(viewModel)
        return viewModel
    }
}

// MARK: - MockGetCurrentUserUseCase

private final class MockGetCurrentUserUseCase: GetCurrentUserUseCase {
    func execute() async throws -> UserProfile {
        throw URLError(.userAuthenticationRequired)
    }
}

private final class MockSaveSalonUseCase: SaveSalonUseCase {
    func execute(salonId: String) async throws {}
}

private final class MockUnsaveSalonUseCase: UnsaveSalonUseCase {
    func execute(salonId: String) async throws {}
}

private final class MockSavedSalonsEventBus: SavedSalonsEventBus {
    var changes: AnyPublisher<SavedSalonChange, Never> { Empty().eraseToAnyPublisher() }
    func notify(_ change: SavedSalonChange) {}
}

@MainActor
private final class MockObserveBookingUseCase: ObserveBookingUseCase {
    func execute(id: String) -> AnyPublisher<Booking?, Never> {
        // Emit nil so Home renders from the feed snapshot (no cache override).
        Just(nil).eraseToAnyPublisher()
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
        categories: [
            AppCategory(id: "1", slug: "nails", name: "Нігті", imageUrl: nil, sortOrder: 0),
            AppCategory(id: "2", slug: "hair", name: "Волосся", imageUrl: nil, sortOrder: 1),
            AppCategory(id: "3", slug: "spa", name: "SPA/Масаж", imageUrl: nil, sortOrder: 2),
            AppCategory(id: "4", slug: "injections", name: "Ін'єкції", imageUrl: nil, sortOrder: 3),
            AppCategory(id: "5", slug: "epilation", name: "Епіляція", imageUrl: nil, sortOrder: 4),
        ],
        nextBooking: NextBooking(
            bookingId: "b1",
            salonId: "s1",
            salonName: "Nail bar: Glossy Room",
            salonCoverImageUrl: nil,
            salonAddressLine: "вул. Зеленицька, 15, 05-091",
            datetime: Date().addingTimeInterval(86400),
            endDatetime: Date().addingTimeInterval(86400 + 7200),
            totalPriceCents: 70000,
            durationMinutes: 90,
            serviceNames: ["Манікюр", "Покриття гель-лаком"],
            services: [],
            bookingUrl: nil,
            timezone: TimeZone(identifier: "Europe/Kyiv")
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
