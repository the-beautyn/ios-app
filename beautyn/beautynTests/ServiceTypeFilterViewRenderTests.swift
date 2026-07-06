import Combine
import SwiftUI
import XCTest
@testable import beautyn

// MARK: - ServiceTypeFilterViewRenderTests
//
// Renders the service-type filter sheet (Figma 143:8965) with mock categories
// to a PNG for visual verification.
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
//     -only-testing:beautynTests/ServiceTypeFilterViewRenderTests

@MainActor
final class ServiceTypeFilterViewRenderTests: XCTestCase {

    func testRenderServiceTypeFilter() async throws {
        let viewModel = ServiceTypeFilterViewModel(
            transition: .init(didTapClose: {}),
            context: ServiceTypeFilterContext(
                initialCategory: [AppCategory].filterPreview.first,
                onApply: { _ in }
            ),
            getAppCategoriesUseCase: MockGetAppCategoriesUseCase()
        )
        let view = ServiceTypeFilterView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "service_type_filter")
    }
}

// MARK: - ServiceTypeFilterViewModelTests

@MainActor
final class ServiceTypeFilterViewModelTests: XCTestCase {

    // Retained until the case deallocates — releasing a @MainActor VM at the
    // end of the test method crashes the runner under Xcode 26 (malloc
    // double-free; same bug as ViewRenderer's window retention).
    private var retainedViewModels: [ServiceTypeFilterViewModel] = []

    func testLoadsCategoriesOnViewTask() async {
        let viewModel = makeViewModel()

        await viewModel.onViewTask()

        XCTAssertEqual(viewModel.categories.map(\.id), [AppCategory].filterPreview.map(\.id))
    }

    func testPreselectsInitialCategory() {
        let initial = [AppCategory].filterPreview[1]
        let viewModel = makeViewModel(initialCategory: initial)

        XCTAssertEqual(viewModel.selectedCategory?.id, initial.id)
    }

    func testTapMovesSingleSelection() async {
        let viewModel = makeViewModel(initialCategory: [AppCategory].filterPreview[0])
        await viewModel.onViewTask()

        viewModel.didTapCategory(viewModel.categories[2])

        XCTAssertEqual(viewModel.selectedCategory?.id, viewModel.categories[2].id)
    }

    func testClearDeselects() async {
        let viewModel = makeViewModel(initialCategory: [AppCategory].filterPreview[0])
        await viewModel.onViewTask()

        viewModel.didTapClear()

        XCTAssertNil(viewModel.selectedCategory)
    }

    func testApplyHandsBackSelectionAndCloses() async {
        var applied: AppCategory?
        var didClose = false
        let viewModel = makeViewModel(
            initialCategory: nil,
            onApply: { applied = $0 },
            didTapClose: { didClose = true }
        )
        await viewModel.onViewTask()

        viewModel.didTapCategory(viewModel.categories[1])
        viewModel.didTapApply()

        XCTAssertEqual(applied?.id, viewModel.categories[1].id)
        XCTAssertTrue(didClose)
    }

    func testApplyAfterClearHandsBackNil() async {
        var applied: AppCategory? = [AppCategory].filterPreview[0]
        let viewModel = makeViewModel(
            initialCategory: [AppCategory].filterPreview[0],
            onApply: { applied = $0 }
        )
        await viewModel.onViewTask()

        viewModel.didTapClear()
        viewModel.didTapApply()

        XCTAssertNil(applied)
    }

    func testApplyBeforeLoadStillHandsBackInitialCategory() {
        // The applied category must survive Застосувати even when the list
        // request hasn't finished (selection is stored as the full model).
        var applied: AppCategory?
        let initial = [AppCategory].filterPreview[2]
        let viewModel = makeViewModel(initialCategory: initial, onApply: { applied = $0 })

        viewModel.didTapApply()

        XCTAssertEqual(applied?.id, initial.id)
    }

    // MARK: - Helpers

    private func makeViewModel(
        initialCategory: AppCategory? = nil,
        onApply: @escaping (AppCategory?) -> Void = { _ in },
        didTapClose: @escaping () -> Void = {}
    ) -> ServiceTypeFilterViewModel {
        let viewModel = ServiceTypeFilterViewModel(
            transition: .init(didTapClose: didTapClose),
            context: ServiceTypeFilterContext(initialCategory: initialCategory, onApply: onApply),
            getAppCategoriesUseCase: MockGetAppCategoriesUseCase()
        )
        retainedViewModels.append(viewModel)
        return viewModel
    }
}

// MARK: - SearchMapCategoryFilterTests
//
// The map VM must carry the applied category into every subsequent search
// query (and drop it again after an empty apply).

@MainActor
final class SearchMapCategoryFilterTests: XCTestCase {

    // Retained until the case deallocates — the VM owns Combine cancellables
    // and releasing it mid-flight crashes under Xcode 26 (see ViewRenderer).
    private var viewModel: SearchMapViewModel!
    private var salonsUseCase: CapturingSearchSalonsUseCase!
    private var regionUseCase: CountingResolveInitialRegionUseCase!
    private var capturedContext: ServiceTypeFilterContext?
    private var capturedSearchContext: SearchInputContext?

    override func setUp() {
        super.setUp()
        salonsUseCase = CapturingSearchSalonsUseCase()
        regionUseCase = CountingResolveInitialRegionUseCase()
        viewModel = SearchMapViewModel(
            transition: .init(
                didTapSalonCard: { _ in },
                didRequireAuth: {},
                didTapOpenSettings: {},
                didTapSearchField: { [weak self] context in
                    self?.capturedSearchContext = context
                },
                didTapSortFilter: { _ in },
                didTapServiceTypeFilter: { [weak self] context in
                    self?.capturedContext = context
                }
            ),
            searchSalonsUseCase: salonsUseCase,
            searchPinsUseCase: StubSearchPinsUseCase(),
            getSearchFilterOptionsUseCase: StubGetSearchFilterOptionsUseCase(),
            resolveInitialRegionUseCase: regionUseCase,
            getUserLocationUseCase: StubGetUserLocationUseCase(),
            observeLocationPermissionUseCase: StubObserveLocationPermissionUseCase(),
            saveSalonUseCase: StubSaveSalonUseCase(),
            unsaveSalonUseCase: StubUnsaveSalonUseCase(),
            savedSalonsEventBus: StubSavedSalonsEventBus(),
            sessionManager: SessionManager(keychainService: KeychainServiceImpl(), defaultsService: DefaultsStorageService())
        )
    }

    func testAppliedCategoryFlowsIntoSearchQueryAndClearsAgain() async throws {
        await viewModel.onViewTask()
        XCTAssertEqual(salonsUseCase.queries.count, 1)
        XCTAssertNil(salonsUseCase.queries.last?.appCategoryIds)

        // Open the sheet: the context carries no category yet.
        viewModel.didTapFilterChip(.serviceType)
        let context = try XCTUnwrap(capturedContext)
        XCTAssertNil(context.initialCategory)

        // Apply "Нігті" → the viewport re-search must carry its id.
        let nails = [AppCategory].filterPreview[0]
        context.onApply(nails)
        try await waitUntil { self.salonsUseCase.queries.count >= 2 }
        XCTAssertEqual(salonsUseCase.queries.last?.appCategoryIds, [nails.id])
        XCTAssertEqual(viewModel.appliedCategory?.id, nails.id)

        // Reopening preselects the applied category.
        viewModel.didTapFilterChip(.serviceType)
        XCTAssertEqual(capturedContext?.initialCategory?.id, nails.id)

        // Applying an empty pick removes the filter from the next search.
        capturedContext?.onApply(nil)
        try await waitUntil { self.salonsUseCase.queries.count >= 3 }
        XCTAssertNil(salonsUseCase.queries.last?.appCategoryIds)
        XCTAssertNil(viewModel.appliedCategory)
    }

    func testHomeCategorySearchResetsQueryAndDateAndReresolvesRegion() async throws {
        await viewModel.onViewTask()
        XCTAssertEqual(regionUseCase.calls, 1)

        // Apply a text query + day filter through the search sheet first, so
        // the chip tap has something to reset.
        viewModel.didTapSearchField()
        let searchContext = try XCTUnwrap(capturedSearchContext)
        searchContext.onApply(SearchSubmission(
            query: "nails",
            location: nil,
            date: Date().addingTimeInterval(86_400)
        ))
        try await waitUntil { self.salonsUseCase.queries.count >= 2 }
        XCTAssertEqual(salonsUseCase.queries.last?.query, "nails")
        XCTAssertNotNil(salonsUseCase.queries.last?.date)

        // Home chip tap after the map is loaded: query + date dropped,
        // category applied, and the region chain (GPS → profile city → …)
        // re-runs.
        let nails = [AppCategory].filterPreview[0]
        viewModel.applyCategorySearch(nails)
        try await waitUntil { self.salonsUseCase.queries.count >= 3 }

        XCTAssertEqual(regionUseCase.calls, 2)
        let query = try XCTUnwrap(salonsUseCase.queries.last)
        XCTAssertNil(query.query)
        XCTAssertNil(query.date)
        XCTAssertEqual(query.appCategoryIds, [nails.id])
        XCTAssertEqual(viewModel.appliedCategory?.id, nails.id)
    }

    func testHomeCategorySearchBeforeInitialLoadRidesAlong() async throws {
        // Chip tapped on the very first switch to the tab — no extra search;
        // the initial load itself must carry the category.
        let hair = [AppCategory].filterPreview[1]
        viewModel.applyCategorySearch(hair)
        await viewModel.onViewTask()

        XCTAssertEqual(regionUseCase.calls, 1)
        XCTAssertEqual(salonsUseCase.queries.count, 1)
        XCTAssertEqual(salonsUseCase.queries.last?.appCategoryIds, [hair.id])
    }

    private func waitUntil(
        timeout: TimeInterval = 2,
        _ condition: @escaping () -> Bool
    ) async throws {
        let start = Date()
        while !condition() {
            if Date().timeIntervalSince(start) > timeout {
                return XCTFail("Timed out waiting for condition")
            }
            try await Task.sleep(for: .milliseconds(20))
        }
    }
}

// MARK: - Mocks

private final class MockGetAppCategoriesUseCase: GetAppCategoriesUseCase {
    func execute() async throws -> [AppCategory] { .filterPreview }
}

@MainActor
private final class CapturingSearchSalonsUseCase: SearchSalonsUseCase {
    private(set) var queries: [SearchQuery] = []

    func execute(_ query: SearchQuery) async throws -> SearchResults {
        queries.append(query)
        return SearchResults(items: [], page: query.page, limit: query.limit, total: 0)
    }
}

private final class StubSearchPinsUseCase: SearchPinsUseCase {
    func execute(_ query: SearchQuery) async throws -> [SearchPin] { [] }
}

private final class StubGetSearchFilterOptionsUseCase: GetSearchFilterOptionsUseCase {
    func execute() async throws -> SearchFilterOptions {
        SearchFilterOptions(sortOptions: [], minPrice: nil, maxPrice: nil)
    }
}

@MainActor
private final class CountingResolveInitialRegionUseCase: ResolveInitialSearchRegionUseCase {
    private(set) var calls = 0

    func execute() async -> SearchRegion {
        calls += 1
        return .kyivFallback
    }
}

private final class StubGetUserLocationUseCase: GetUserLocationUseCase {
    func execute() async -> GeoPoint? { nil }
}

private final class StubObserveLocationPermissionUseCase: ObserveLocationPermissionUseCase {
    func execute() -> AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
    }
}

private final class StubSaveSalonUseCase: SaveSalonUseCase {
    func execute(salonId: String) async throws {}
}

private final class StubUnsaveSalonUseCase: UnsaveSalonUseCase {
    func execute(salonId: String) async throws {}
}

private final class StubSavedSalonsEventBus: SavedSalonsEventBus {
    var changes: AnyPublisher<SavedSalonChange, Never> { Empty().eraseToAnyPublisher() }
    func notify(_ change: SavedSalonChange) {}
}

// MARK: - Preview Data

private extension [AppCategory] {

    static let filterPreview: [AppCategory] = [
        AppCategory(id: "cat-nails", slug: "nails", name: "Нігті", imageUrl: nil, sortOrder: 1),
        AppCategory(id: "cat-hair", slug: "hair", name: "Волосся", imageUrl: nil, sortOrder: 2),
        AppCategory(id: "cat-face", slug: "face", name: "Обличчя", imageUrl: nil, sortOrder: 3),
        AppCategory(id: "cat-brows", slug: "brows-lashes", name: "Брови й вії", imageUrl: nil, sortOrder: 4),
        AppCategory(id: "cat-makeup", slug: "makeup", name: "Макіяж", imageUrl: nil, sortOrder: 5),
        AppCategory(id: "cat-epilation", slug: "epilation", name: "Епіляція", imageUrl: nil, sortOrder: 6),
        AppCategory(id: "cat-spa", slug: "spa-massage", name: "SPA/Масаж", imageUrl: nil, sortOrder: 7),
        AppCategory(id: "cat-injections", slug: "injections", name: "Інʼєкції", imageUrl: nil, sortOrder: 8),
        AppCategory(id: "cat-trichology", slug: "trichology", name: "Трихологія", imageUrl: nil, sortOrder: 9),
        AppCategory(id: "cat-men", slug: "for-men", name: "Для чоловіків", imageUrl: nil, sortOrder: 10),
        AppCategory(id: "cat-other", slug: "other", name: "Інше", imageUrl: nil, sortOrder: 11)
    ]
}
