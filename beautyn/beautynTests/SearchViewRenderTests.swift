import Combine
import SwiftUI
import XCTest
@testable import beautyn

// MARK: - SearchViewRenderTests
//
// Renders the text-search sheet (Figma 143:8526) with mock data through the
// normal ViewModel lifecycle (onViewTask → history / suggestions → apply).
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
//     -only-testing:beautynTests/SearchViewRenderTests

@MainActor
final class SearchViewRenderTests: XCTestCase {

    /// Empty field + "Попередній пошук" — needs an authenticated session,
    /// or the VM skips the history fetch entirely.
    func testRenderSearchHistory() async throws {
        let sessionManager = makeSessionManager()
        sessionManager.saveSession(accessToken: "render", refreshToken: "render", phoneVerificationRequired: false)
        defer { sessionManager.clearSession() }

        let viewModel = makeViewModel(sessionManager: sessionManager)
        let view = SearchView(viewModel: viewModel, autoFocusesSearchField: false)
        try await ViewRenderer.render(view, name: "search_input_history")
    }

    /// Typed query + "Салони" suggestions (anonymous — no history section).
    func testRenderSearchResults() async throws {
        let viewModel = makeViewModel(initialQuery: "Nail", sessionManager: makeSessionManager())
        let view = SearchView(viewModel: viewModel, autoFocusesSearchField: false)
        try await ViewRenderer.render(view, name: "search_input_suggestions")
    }

    /// A stale (past) applied day is ignored — the pill falls back to the
    /// placeholder instead of showing yesterday's date.
    func testPastAppliedDateIsIgnored() {
        let past = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        let staleViewModel = makeViewModel(initialDate: past, sessionManager: makeSessionManager())
        XCTAssertEqual(staleViewModel.dateTitle, Localization.searchDatePlaceholder)

        let future = Calendar.current.date(byAdding: .day, value: 2, to: Date())
        let freshViewModel = makeViewModel(initialDate: future, sessionManager: makeSessionManager())
        XCTAssertNotEqual(freshViewModel.dateTitle, Localization.searchDatePlaceholder)

        // Deallocating these @MainActor VMs at method exit trips a malloc
        // double-free under Xcode 26 — keep them alive until teardown.
        addTeardownBlock { _ = staleViewModel; _ = freshViewModel }
    }

    // MARK: - Helpers

    private func makeViewModel(
        initialQuery: String? = nil,
        initialDate: Date? = nil,
        sessionManager: SessionManager
    ) -> SearchViewModel {
        SearchViewModel(
            transition: .init(
                didTapClose: {},
                didTapLocationField: { _ in },
                didTapDateField: { _, _ in },
                didSelectSalon: { _, _ in },
                didSubmit: { _ in }
            ),
            initialQuery: initialQuery,
            initialLocation: nil,
            initialDate: initialDate,
            mapCenter: GeoPoint(latitude: 50.4501, longitude: 30.5234),
            getSearchHistoryUseCase: MockGetSearchHistoryUseCase(),
            clearSearchHistoryUseCase: MockClearSearchHistoryUseCase(),
            deleteSearchHistoryItemUseCase: MockDeleteSearchHistoryItemUseCase(),
            searchSalonsUseCase: MockSheetSearchSalonsUseCase(),
            sessionManager: sessionManager
        )
    }

    private func makeSessionManager() -> SessionManager {
        SessionManager(keychainService: KeychainServiceImpl(), defaultsService: DefaultsStorageService())
    }
}

// MARK: - SearchDatePickerViewRenderTests

@MainActor
final class SearchDatePickerViewRenderTests: XCTestCase {

    /// Date page pushed inside the search sheet (Figma 143:8732, date section
    /// only) — calendar with a selected future day + Очистити/Застосувати bar.
    func testRenderSearchDatePicker() async throws {
        let viewModel = SearchDatePickerViewModel(
            transition: .init(didTapBack: {}, didApply: { _ in }),
            initialDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())
        )
        let view = SearchDatePickerView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "search_date_picker")
    }
}

// MARK: - SearchLocationViewRenderTests

@MainActor
final class SearchLocationViewRenderTests: XCTestCase {

    /// Empty state — field + "Моя геолокація" row, matching Figma 143:8586.
    func testRenderSearchLocation() async throws {
        let viewModel = SearchLocationViewModel(
            transition: .init(
                didTapBack: {},
                didSelectLocation: { _ in },
                didTapOpenSettings: {}
            ),
            getLocationCompletionsUseCase: MockGetLocationCompletionsUseCase(),
            resolveLocationCompletionUseCase: MockResolveLocationCompletionUseCase(),
            getUserLocationUseCase: MockGetUserLocationUseCase(),
            reverseGeocodeNameUseCase: MockReverseGeocodeNameUseCase(),
            observeLocationPermissionUseCase: MockObserveLocationPermissionUseCase()
        )
        let view = SearchLocationView(viewModel: viewModel, autoFocusesSearchField: false)
        try await ViewRenderer.render(view, name: "search_location")
    }
}

// MARK: - Mocks

private final class MockGetSearchHistoryUseCase: GetSearchHistoryUseCase {
    func execute(limit: Int) async throws -> [SearchHistoryItem] {
        [
            SearchHistoryItem(id: "h1", salonId: "s1", name: "Yala Spa", city: "Київ", imageUrl: nil, point: GeoPoint(latitude: 50.4501, longitude: 30.5234)),
            SearchHistoryItem(id: "h2", salonId: "s2", name: "Nail bar: Glossy Room", city: "Київ", imageUrl: nil, point: GeoPoint(latitude: 50.4501, longitude: 30.5234)),
            SearchHistoryItem(id: "h3", salonId: "s3", name: "Brow Bar Kyiv", city: "Київ", imageUrl: nil, point: GeoPoint(latitude: 50.4501, longitude: 30.5234))
        ]
    }
}

private final class MockClearSearchHistoryUseCase: ClearSearchHistoryUseCase {
    func execute() async throws {}
}

private final class MockDeleteSearchHistoryItemUseCase: DeleteSearchHistoryItemUseCase {
    func execute(id: String) async throws {}
}

private final class MockSheetSearchSalonsUseCase: SearchSalonsUseCase {
    func execute(_ query: SearchQuery) async throws -> SearchResults {
        let salons = [
            SearchSalon(id: "s1", name: "Nail bar: Glossy Room", address: "вул. Зеленицька, 15", rating: 4.5, distanceKm: 0.8, imageUrl: nil, latitude: 50.4485, longitude: 30.519, isSaved: false),
            SearchSalon(id: "s2", name: "Clipse Manicure", address: "вул. Хрещатик, 22", rating: 4.8, distanceKm: 1.2, imageUrl: nil, latitude: 50.447, longitude: 30.524, isSaved: false),
            SearchSalon(id: "s3", name: "G-bar", address: "вул. Франка, 10", rating: 4.6, distanceKm: 2.0, imageUrl: nil, latitude: 50.453, longitude: 30.529, isSaved: false)
        ]
        return SearchResults(items: salons, page: 1, limit: 10, total: 3)
    }
}

private final class MockGetLocationCompletionsUseCase: GetLocationCompletionsUseCase {
    func execute(query: String) async -> [SearchLocationCompletion] {
        [
            SearchLocationCompletion(id: 0, title: "Київ", subtitle: "Україна", batchId: UUID()),
            SearchLocationCompletion(id: 1, title: "Київ, вул. Хрещатик", subtitle: "Україна", batchId: UUID())
        ]
    }
}

private final class MockResolveLocationCompletionUseCase: ResolveLocationCompletionUseCase {
    func execute(_ completion: SearchLocationCompletion) async -> SearchLocation? {
        SearchLocation(point: GeoPoint(latitude: 50.4501, longitude: 30.5234), name: completion.title)
    }
}

private final class MockGetUserLocationUseCase: GetUserLocationUseCase {
    func execute() async -> GeoPoint? { nil }
}

private final class MockReverseGeocodeNameUseCase: ReverseGeocodeNameUseCase {
    func execute(_ point: GeoPoint) async -> String? { "Київ" }
}

private final class MockObserveLocationPermissionUseCase: ObserveLocationPermissionUseCase {
    func execute() -> AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
    }
}
