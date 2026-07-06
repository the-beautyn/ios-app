import Combine
import MapKit
import SwiftUI
import XCTest
@testable import beautyn

// MARK: - SearchMapViewRenderTests
//
// Renders the actual SearchMapView with mock data to a PNG for visual verification.
// The mock use case returns preview salons, which flow through the normal
// ViewModel lifecycle (onViewTask → resolve region → performSearch → apply).
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
//     -only-testing:beautynTests/SearchMapViewRenderTests

@MainActor
final class SearchMapViewRenderTests: XCTestCase {

    func testRenderSearch() async throws {
        let viewModel = makeViewModel()
        // showsLiveMap: false — snapshotting a live MKMapView segfaults in the
        // render harness (concurrent tile decode during UIGraphicsImageRenderer).
        let view = SearchMapView(viewModel: viewModel, showsLiveMap: false)
        try await ViewRenderer.render(view, name: "search")
    }

    func testRenderSearchSheetBottom() async throws {
        let viewModel = makeViewModel()
        let view = SearchMapView(viewModel: viewModel, showsLiveMap: false, initialSheetSnap: SearchMapView.bottomSnap)
        try await ViewRenderer.render(view, name: "search_sheet_bottom")
    }

    func testRenderSearchSheetTop() async throws {
        let viewModel = makeViewModel()
        let view = SearchMapView(viewModel: viewModel, showsLiveMap: false, initialSheetSnap: SearchMapView.topSnap)
        try await ViewRenderer.render(view, name: "search_sheet_top")
    }

    // MARK: - Helpers

    private func makeViewModel() -> SearchMapViewModel {
        SearchMapViewModel(
            transition: .init(
                didTapSalonCard: { _ in },
                didRequireAuth: {},
                didTapOpenSettings: {},
                didTapSearchField: { _ in },
                didTapSortFilter: { _ in },
                didTapServiceTypeFilter: { _ in }
            ),
            searchSalonsUseCase: MockSearchSalonsUseCase(),
            searchPinsUseCase: MockSearchPinsUseCase(),
            getSearchFilterOptionsUseCase: MockGetSearchFilterOptionsUseCase(),
            resolveInitialRegionUseCase: MockResolveInitialRegionUseCase(),
            getUserLocationUseCase: MockGetUserLocationUseCase(),
            observeLocationPermissionUseCase: MockObserveLocationPermissionUseCase(),
            saveSalonUseCase: MockSaveSalonUseCase(),
            unsaveSalonUseCase: MockUnsaveSalonUseCase(),
            savedSalonsEventBus: MockSavedSalonsEventBus(),
            sessionManager: SessionManager(keychainService: KeychainServiceImpl(), defaultsService: DefaultsStorageService())
        )
    }
}

// MARK: - Mocks

private final class MockSearchSalonsUseCase: SearchSalonsUseCase {
    func execute(_ query: SearchQuery) async throws -> SearchResults {
        SearchResults(items: .searchPreview, page: 1, limit: 20, total: 1576)
    }
}

private final class MockSearchPinsUseCase: SearchPinsUseCase {
    func execute(_ query: SearchQuery) async throws -> [SearchPin] {
        [SearchSalon].searchPreview.compactMap { salon in
            guard let latitude = salon.latitude, let longitude = salon.longitude else { return nil }
            return SearchPin(id: salon.id, latitude: latitude, longitude: longitude)
        }
    }
}

private final class MockGetSearchFilterOptionsUseCase: GetSearchFilterOptionsUseCase {
    func execute() async throws -> SearchFilterOptions {
        SearchFilterOptions(
            sortOptions: [.distance, .ratingDesc, .priceAsc, .priceDesc, .popular],
            minPrice: 100,
            maxPrice: 1_150
        )
    }
}

private final class MockResolveInitialRegionUseCase: ResolveInitialSearchRegionUseCase {
    func execute() async -> SearchRegion { .kyivFallback }
}

private final class MockGetUserLocationUseCase: GetUserLocationUseCase {
    func execute() async -> GeoPoint? { nil }
}

private final class MockObserveLocationPermissionUseCase: ObserveLocationPermissionUseCase {
    func execute() -> AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
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

// MARK: - SearchMapClusteringTests

@MainActor
final class SearchMapClusteringTests: XCTestCase {

    private let viewport = SearchViewport(neLat: 50.5, neLng: 30.6, swLat: 50.4, swLng: 30.4)

    func testLonePinsStaySingles() {
        // Opposite corners of the viewport — far beyond one grid cell apart.
        let pins = [
            SearchPin(id: "a", latitude: 50.41, longitude: 30.41),
            SearchPin(id: "b", latitude: 50.49, longitude: 30.59),
        ]
        let items = SearchMapClusterBuilder.makeItems(pins: pins, viewport: viewport)

        XCTAssertEqual(items.count, 2)
        for item in items {
            guard case .pin = item else {
                return XCTFail("Expected singles, got \(item)")
            }
        }
    }

    func testSmallGroupsStayIndividualDots() {
        // Four pins in one grid cell — below the 5-pin cluster threshold.
        let pins = (0..<4).map { index in
            SearchPin(id: "p\(index)", latitude: 50.451 + Double(index) * 0.001, longitude: 30.451)
        }
        let items = SearchMapClusterBuilder.makeItems(pins: pins, viewport: viewport)

        XCTAssertEqual(items.count, 4)
        for item in items {
            guard case .pin = item else {
                return XCTFail("Expected singles below the threshold, got \(item)")
            }
        }
    }

    func testNearbyPinsMergeIntoCluster() {
        // Five pins within one grid cell (cell ≈ 0.0125° at this span).
        let pins = (0..<5).map { index in
            SearchPin(id: "p\(index)", latitude: 50.451 + Double(index) * 0.001, longitude: 30.452)
        }
        let items = SearchMapClusterBuilder.makeItems(pins: pins, viewport: viewport)

        XCTAssertEqual(items.count, 1)
        guard case .cluster(let cluster) = items[0] else {
            return XCTFail("Expected a cluster, got \(items[0])")
        }
        XCTAssertEqual(cluster.count, 5)
        XCTAssertEqual(cluster.coordinate.latitude, 50.453, accuracy: 0.0001)
        XCTAssertEqual(cluster.minLat, 50.451)
        XCTAssertEqual(cluster.maxLat, 50.455)
    }

    func testAnnotationCountStaysBoundedByGrid() {
        // 500 pins spread across the viewport — annotations must stay ≤ grid capacity.
        let pins = (0..<500).map { index in
            SearchPin(
                id: "p\(index)",
                latitude: 50.4 + Double(index % 25) * 0.004,
                longitude: 30.4 + Double(index / 25) * 0.01
            )
        }
        let items = SearchMapClusterBuilder.makeItems(pins: pins, viewport: viewport)

        XCTAssertLessThanOrEqual(items.count, 81) // 8×8 grid + boundary spill
        XCTAssertEqual(
            items.reduce(0) { sum, item in
                switch item {
                case .pin: return sum + 1
                case .cluster(let cluster): return sum + cluster.count
                }
            },
            500,
            "Every pin must be represented exactly once"
        )
    }
}

// MARK: - SearchMapCameraTests

@MainActor
final class SearchMapCameraTests: XCTestCase {

    func testRegionViewportRoundTrip() {
        let region = SearchMapCamera.makeRegion(SearchRegion(
            center: GeoPoint(latitude: 50.45, longitude: 30.52),
            spanMeters: 10_000
        ))
        let viewport = SearchMapCamera.makeViewport(region)

        XCTAssertEqual((viewport.neLat + viewport.swLat) / 2, 50.45, accuracy: 0.0001)
        XCTAssertEqual((viewport.neLng + viewport.swLng) / 2, 30.52, accuracy: 0.0001)
        XCTAssertEqual(viewport.latSpan, region.span.latitudeDelta, accuracy: 0.000001)
        XCTAssertEqual(viewport.lngSpan, region.span.longitudeDelta, accuracy: 0.000001)
    }

    func testFocusedRegionCentersInVisibleStrip() {
        let coordinate = CLLocationCoordinate2D(latitude: 50.45, longitude: 30.52)
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)

        // headerFraction 0.13, sheet 0.6 → visible center at 0.265 of screen
        // height → the region center shifts south by (0.5 − 0.265) × latSpan.
        let region = SearchMapCamera.focusedRegion(on: coordinate, span: span, sheetHeightFraction: 0.6)
        let expectedOffset = (0.5 - 0.265) * span.latitudeDelta
        XCTAssertEqual(region.center.latitude, coordinate.latitude - expectedOffset, accuracy: 0.000001)
        XCTAssertEqual(region.center.longitude, coordinate.longitude)
        XCTAssertEqual(region.span.latitudeDelta, span.latitudeDelta)

        // A strip centered mid-screen (visibleCenterFraction == 0.5) means no
        // shift: header 0.13 balanced by a sheet of the same height.
        let balanced = SearchMapCamera.focusedRegion(
            on: coordinate,
            span: span,
            sheetHeightFraction: SearchMapCamera.headerHeightFraction
        )
        XCTAssertEqual(balanced.center.latitude, coordinate.latitude, accuracy: 0.000001)
    }

    func testStripFittedRegionScalesToVisibleStrip() {
        let center = GeoPoint(latitude: 50.45, longitude: 30.52)
        let base = SearchMapCamera.makeRegion(SearchRegion(center: center, spanMeters: 4_000))

        // Sheet at medium (0.6): visible strip = 1 − 0.13 − 0.6 = 0.27.
        let fitted = SearchMapCamera.stripFittedRegion(center: center, spanMeters: 4_000, sheetHeightFraction: 0.6)
        XCTAssertEqual(fitted.span.latitudeDelta, base.span.latitudeDelta / 0.27, accuracy: 0.000001)
        XCTAssertEqual(fitted.span.longitudeDelta, base.span.longitudeDelta, accuracy: 0.000001)
        XCTAssertLessThan(fitted.center.latitude, center.latitude, "Center shifts south into the visible strip")

        // Sheet at the top snap (0.87): the 0.15 floor prevents a degenerate strip.
        let floored = SearchMapCamera.stripFittedRegion(center: center, spanMeters: 4_000, sheetHeightFraction: 0.87)
        XCTAssertEqual(floored.span.latitudeDelta, base.span.latitudeDelta / 0.15, accuracy: 0.000001)
    }

    func testFocusSpanNeverZoomsOut() {
        // Zoomed far out → clamps to the cap.
        let wide = SearchViewport(neLat: 50.6, neLng: 30.7, swLat: 50.3, swLng: 30.3)
        let clamped = SearchMapCamera.focusSpan(currentViewport: wide)
        XCTAssertEqual(clamped.latitudeDelta, SearchMapCamera.minClusterZoomSpan)

        // Already closer than the cap → keeps the tighter zoom.
        let tight = SearchViewport(neLat: 50.451, neLng: 30.521, swLat: 50.45, swLng: 30.52)
        let kept = SearchMapCamera.focusSpan(currentViewport: tight)
        XCTAssertEqual(kept.latitudeDelta, 0.001, accuracy: 0.000001)

        // No viewport yet → the cap itself.
        let fallback = SearchMapCamera.focusSpan(currentViewport: nil, cappedAt: SearchMapCamera.userLocationFocusSpan)
        XCTAssertEqual(fallback.latitudeDelta, SearchMapCamera.userLocationFocusSpan)
    }

    func testClusterZoomSpanUsesPaddedBoundingBox() {
        let cluster = SearchMapCluster(
            id: "c", coordinate: CLLocationCoordinate2D(latitude: 50.45, longitude: 30.52),
            count: 6, minLat: 50.44, maxLat: 50.46, minLng: 30.51, maxLng: 30.53
        )
        let span = SearchMapCamera.clusterZoomSpan(for: cluster)
        XCTAssertEqual(span.latitudeDelta, 0.02 * 1.6, accuracy: 0.000001)

        // A pixel-tight cluster is floored at the minimum zoom span.
        let tight = SearchMapCluster(
            id: "t", coordinate: CLLocationCoordinate2D(latitude: 50.45, longitude: 30.52),
            count: 6, minLat: 50.45, maxLat: 50.45, minLng: 30.52, maxLng: 30.52
        )
        let floored = SearchMapCamera.clusterZoomSpan(for: tight)
        XCTAssertEqual(floored.latitudeDelta, SearchMapCamera.minClusterZoomSpan)
    }

    func testFallbackRadiusMirrorsBackendTable() {
        XCTAssertEqual(SearchMapCamera.fallbackRadiusKm(for: .city), 7)
        XCTAssertEqual(SearchMapCamera.fallbackRadiusKm(for: .neighborhood), 3)
        XCTAssertEqual(SearchMapCamera.fallbackRadiusKm(for: .address), 2)
        XCTAssertEqual(SearchMapCamera.fallbackRadiusKm(for: .poi), 0.5)
        XCTAssertEqual(SearchMapCamera.fallbackRadiusKm(for: .unknown), 3)
    }
}

// MARK: - SearchSortViewRenderTests
//
// Renders the sort/price filter sheet (Figma 143:8873). The render harness
// hosts the AppBottomSheet content fullscreen.

@MainActor
final class SearchSortViewRenderTests: XCTestCase {

    func testRenderSearchSortDefault() async throws {
        let viewModel = makeViewModel(initialSort: nil, initialPriceMin: nil, initialPriceMax: nil)
        let view = SearchSortView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "search_sort_default")
    }

    func testRenderSearchSortFilled() async throws {
        let viewModel = makeViewModel(initialSort: .popular, initialPriceMin: 300, initialPriceMax: 800)
        let view = SearchSortView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "search_sort_filled")
    }

    private func makeViewModel(
        initialSort: SearchSortOption?,
        initialPriceMin: Double?,
        initialPriceMax: Double?
    ) -> SearchSortViewModel {
        SearchSortViewModel(
            transition: .init(didTapClose: {}),
            context: SearchSortContext(
                initialSort: initialSort,
                initialPriceMin: initialPriceMin,
                initialPriceMax: initialPriceMax,
                filterOptions: SearchFilterOptions(
                    sortOptions: [.distance, .ratingDesc, .priceAsc, .priceDesc, .popular],
                    minPrice: 100,
                    maxPrice: 1_150
                ),
                onApply: { _ in }
            )
        )
    }
}

// MARK: - SearchSortViewModelTests

@MainActor
final class SearchSortViewModelTests: XCTestCase {

    func testApplyAtTrackEdgesOmitsBothPriceFilters() {
        // 130…1 240 snaps outward to the 100-step: track 100…1 300.
        let viewModel = makeViewModel(minPrice: 130, maxPrice: 1_240)
        XCTAssertEqual(viewModel.priceLowerBound, 100)
        XCTAssertEqual(viewModel.priceUpperBound, 1_300)
        XCTAssertEqual(viewModel.priceLowerValue, 100)
        XCTAssertEqual(viewModel.priceUpperValue, 1_300)

        var submitted: SearchSortSubmission?
        submissionHandler = { submitted = $0 }
        viewModel.didTapApply()
        // Applying is immediate — the map refreshes behind the sliding sheet.
        XCTAssertNotNil(submitted)
        XCTAssertNil(submitted?.priceMin)
        XCTAssertNil(submitted?.priceMax)
        XCTAssertNil(submitted?.sort)
    }

    func testApplyInsideTrackSendsBothPriceFilters() {
        let viewModel = makeViewModel(minPrice: 100, maxPrice: 1_200)

        viewModel.priceLowerValue = 300
        viewModel.priceUpperValue = 800
        viewModel.didSelectSort(.priceAsc)

        var submitted: SearchSortSubmission?
        submissionHandler = { submitted = $0 }
        viewModel.didTapApply()
        XCTAssertEqual(submitted?.priceMin, 300)
        XCTAssertEqual(submitted?.priceMax, 800)
        XCTAssertEqual(submitted?.sort, .priceAsc)
    }

    func testClearResetsControlsInPlace() {
        let viewModel = makeViewModel(
            minPrice: 100, maxPrice: 1_200,
            initialSort: .popular, initialPriceMin: 300, initialPriceMax: 800
        )

        XCTAssertEqual(viewModel.selectedSort, .popular)
        XCTAssertEqual(viewModel.priceLowerValue, 300)
        XCTAssertEqual(viewModel.priceUpperValue, 800)

        viewModel.didTapClear()
        XCTAssertNil(viewModel.selectedSort)
        XCTAssertEqual(viewModel.priceLowerValue, viewModel.priceLowerBound)
        XCTAssertEqual(viewModel.priceUpperValue, viewModel.priceUpperBound)
    }

    func testAppliedRangeOutsideTrackIsClamped() {
        // Applied 50…2 800 earlier, but the global track is 100…1 000.
        let viewModel = makeViewModel(minPrice: 100, maxPrice: 1_000, initialPriceMin: 50, initialPriceMax: 2_800)

        XCTAssertEqual(viewModel.priceLowerValue, 100)
        XCTAssertEqual(viewModel.priceUpperValue, 1_000)
    }

    func testCollapsedAppliedRangeKeepsKnobSeparation() {
        // A range applied against the wide fallback track (2 500…2 800) gets
        // pinned to the edge of the real, narrower track — the knobs must
        // still open one step apart, never collapsed.
        let viewModel = makeViewModel(minPrice: 100, maxPrice: 1_200, initialPriceMin: 2_500, initialPriceMax: 2_800)

        XCTAssertEqual(viewModel.priceUpperValue, 1_200)
        XCTAssertEqual(viewModel.priceLowerValue, 1_100)
    }

    func testMissingOptionsFallBackToDefaults() {
        let viewModel = makeViewModel(filterOptions: nil)

        XCTAssertEqual(viewModel.priceLowerBound, SearchSortViewModel.fallbackLowerBound)
        XCTAssertEqual(viewModel.priceUpperBound, SearchSortViewModel.fallbackUpperBound)
        XCTAssertEqual(viewModel.sortOptions, [.ratingDesc, .popular, .distance, .priceAsc])
    }

    func testSortRowsNarrowToServerOptions() {
        let viewModel = makeViewModel(filterOptions: SearchFilterOptions(
            sortOptions: [.distance, .ratingDesc],
            minPrice: 100,
            maxPrice: 500
        ))

        XCTAssertEqual(viewModel.sortOptions, [.ratingDesc, .distance])
    }

    // MARK: - Helpers

    private var submissionHandler: (SearchSortSubmission) -> Void = { _ in }
    /// Deallocating a @MainActor VM (Combine publishers) inside a sync test
    /// crashes the runner on Xcode 26 — keep them alive until suite teardown.
    private var retainedViewModels: [SearchSortViewModel] = []

    private func makeViewModel(
        minPrice: Double?,
        maxPrice: Double?,
        initialSort: SearchSortOption? = nil,
        initialPriceMin: Double? = nil,
        initialPriceMax: Double? = nil
    ) -> SearchSortViewModel {
        makeViewModel(
            filterOptions: SearchFilterOptions(
                sortOptions: [.distance, .ratingDesc, .priceAsc, .priceDesc, .popular],
                minPrice: minPrice,
                maxPrice: maxPrice
            ),
            initialSort: initialSort,
            initialPriceMin: initialPriceMin,
            initialPriceMax: initialPriceMax
        )
    }

    private func makeViewModel(
        filterOptions: SearchFilterOptions?,
        initialSort: SearchSortOption? = nil,
        initialPriceMin: Double? = nil,
        initialPriceMax: Double? = nil
    ) -> SearchSortViewModel {
        let viewModel = SearchSortViewModel(
            transition: .init(didTapClose: {}),
            context: SearchSortContext(
                initialSort: initialSort,
                initialPriceMin: initialPriceMin,
                initialPriceMax: initialPriceMax,
                filterOptions: filterOptions,
                onApply: { [weak self] in self?.submissionHandler($0) }
            )
        )
        retainedViewModels.append(viewModel)
        return viewModel
    }
}

// MARK: - SearchMapSortApplyTests
//
// Regression: applying a sort/price submission must fire a re-search
// immediately — even when the initial load failed and `currentViewport`
// was never set (the map then re-uses the last ATTEMPTED viewport).

@MainActor
final class SearchMapSortApplyTests: XCTestCase {

    private var retainedViewModels: [SearchMapViewModel] = []

    func testApplyingSortSubmissionRefreshesImmediately() async throws {
        let salonsUseCase = CountingSearchSalonsUseCase()
        let viewModel = makeViewModel(salonsUseCase: salonsUseCase)

        await viewModel.onViewTask()
        let callsAfterInitialLoad = salonsUseCase.calls.count

        viewModel.didTapFilterChip(.sort)
        let context = try XCTUnwrap(capturedContext)
        context.onApply(SearchSortSubmission(sort: .priceAsc, priceMin: 300, priceMax: 800))

        await waitForCalls(beyond: callsAfterInitialLoad, in: salonsUseCase)

        XCTAssertGreaterThan(salonsUseCase.calls.count, callsAfterInitialLoad)
        let lastQuery = try XCTUnwrap(salonsUseCase.calls.last)
        XCTAssertEqual(lastQuery.sortBy, .priceAsc)
        XCTAssertEqual(lastQuery.priceMin, 300)
        XCTAssertEqual(lastQuery.priceMax, 800)
    }

    func testApplyRefreshesEvenAfterFailedInitialLoad() async throws {
        let salonsUseCase = CountingSearchSalonsUseCase()
        salonsUseCase.shouldFail = true
        let viewModel = makeViewModel(salonsUseCase: salonsUseCase)

        await viewModel.onViewTask() // initial search fails — currentViewport stays nil
        salonsUseCase.shouldFail = false
        let callsAfterInitialLoad = salonsUseCase.calls.count

        viewModel.didTapFilterChip(.price)
        let context = try XCTUnwrap(capturedContext)
        context.onApply(SearchSortSubmission(sort: nil, priceMin: nil, priceMax: 500))

        await waitForCalls(beyond: callsAfterInitialLoad, in: salonsUseCase)
        XCTAssertGreaterThan(salonsUseCase.calls.count, callsAfterInitialLoad)
        XCTAssertEqual(salonsUseCase.calls.last?.priceMax, 500)
    }

    // MARK: - Section presets (Home section-header taps)

    func testApplySectionSearchAppliesAllStateAndSearches() async throws {
        let salonsUseCase = CountingSearchSalonsUseCase()
        let viewModel = makeViewModel(salonsUseCase: salonsUseCase)

        await viewModel.onViewTask()
        let callsAfterInitialLoad = salonsUseCase.calls.count

        let date = ApiDateFormatter.date(from: "2099-01-15")
        viewModel.applySectionSearch(SectionSearchPreset(
            query: "манікюр",
            category: AppCategory(id: "cat1", slug: "nails", name: "Нігті", imageUrl: nil, sortOrder: 0),
            sortBy: .popular,
            priceMin: 100,
            priceMax: 900,
            date: date
        ))

        await waitForCalls(beyond: callsAfterInitialLoad, in: salonsUseCase)
        let lastQuery = try XCTUnwrap(salonsUseCase.calls.last)
        XCTAssertEqual(lastQuery.query, "манікюр")
        XCTAssertEqual(lastQuery.appCategoryIds, ["cat1"])
        XCTAssertEqual(lastQuery.sortBy, .popular)
        XCTAssertEqual(lastQuery.priceMin, 100)
        XCTAssertEqual(lastQuery.priceMax, 900)
        XCTAssertEqual(lastQuery.date, date)
    }

    func testApplySectionSearchBeforeInitialLoadRidesAlong() async throws {
        let salonsUseCase = CountingSearchSalonsUseCase()
        let viewModel = makeViewModel(salonsUseCase: salonsUseCase)

        // Preset lands before the tab's first load — the applied state must
        // ride along with onViewTask's own search.
        viewModel.applySectionSearch(SectionSearchPreset(
            query: nil, category: nil, sortBy: .ratingDesc,
            priceMin: nil, priceMax: 500, date: nil
        ))
        await viewModel.onViewTask()

        let firstQuery = try XCTUnwrap(salonsUseCase.calls.first)
        XCTAssertEqual(firstQuery.sortBy, .ratingDesc)
        XCTAssertEqual(firstQuery.priceMax, 500)
    }

    func testApplySectionSearchReplacesPreviousFilters() async throws {
        let salonsUseCase = CountingSearchSalonsUseCase()
        let viewModel = makeViewModel(salonsUseCase: salonsUseCase)

        await viewModel.onViewTask()
        let callsAfterInitialLoad = salonsUseCase.calls.count
        viewModel.didTapFilterChip(.sort)
        let context = try XCTUnwrap(capturedContext)
        context.onApply(SearchSortSubmission(sort: .priceAsc, priceMin: 300, priceMax: 800))
        await waitForCalls(beyond: callsAfterInitialLoad, in: salonsUseCase)
        let callsAfterSort = salonsUseCase.calls.count

        // A filterless section clears everything back to a plain nearby search.
        viewModel.applySectionSearch(SectionSearchPreset(
            query: nil, category: nil, sortBy: nil,
            priceMin: nil, priceMax: nil, date: nil
        ))

        await waitForCalls(beyond: callsAfterSort, in: salonsUseCase)
        let lastQuery = try XCTUnwrap(salonsUseCase.calls.last)
        XCTAssertNil(lastQuery.sortBy)
        XCTAssertNil(lastQuery.priceMin)
        XCTAssertNil(lastQuery.priceMax)
        XCTAssertNil(lastQuery.appCategoryIds)
        XCTAssertNil(lastQuery.query)
    }

    // MARK: - Helpers

    private var capturedContext: SearchSortContext?

    /// `searchNow` hops through a Task — poll (bounded) instead of a fixed
    /// sleep so the tests don't flake on loaded CI machines.
    private func waitForCalls(beyond count: Int, in useCase: CountingSearchSalonsUseCase) async {
        for _ in 0..<100 {
            if useCase.calls.count > count { return }
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    private func makeViewModel(salonsUseCase: CountingSearchSalonsUseCase) -> SearchMapViewModel {
        let viewModel = SearchMapViewModel(
            transition: .init(
                didTapSalonCard: { _ in },
                didRequireAuth: {},
                didTapOpenSettings: {},
                didTapSearchField: { _ in },
                didTapSortFilter: { [weak self] in self?.capturedContext = $0 },
                didTapServiceTypeFilter: { _ in }
            ),
            searchSalonsUseCase: salonsUseCase,
            searchPinsUseCase: MockSearchPinsUseCase(),
            getSearchFilterOptionsUseCase: MockGetSearchFilterOptionsUseCase(),
            resolveInitialRegionUseCase: MockResolveInitialRegionUseCase(),
            getUserLocationUseCase: MockGetUserLocationUseCase(),
            observeLocationPermissionUseCase: MockObserveLocationPermissionUseCase(),
            saveSalonUseCase: MockSaveSalonUseCase(),
            unsaveSalonUseCase: MockUnsaveSalonUseCase(),
            savedSalonsEventBus: MockSavedSalonsEventBus(),
            sessionManager: SessionManager(keychainService: KeychainServiceImpl(), defaultsService: DefaultsStorageService())
        )
        retainedViewModels.append(viewModel)
        return viewModel
    }
}

private final class CountingSearchSalonsUseCase: SearchSalonsUseCase {
    private(set) var calls: [SearchQuery] = []
    var shouldFail = false

    func execute(_ query: SearchQuery) async throws -> SearchResults {
        calls.append(query)
        if shouldFail {
            throw URLError(.notConnectedToInternet)
        }
        return SearchResults(items: .searchPreview, page: 1, limit: 20, total: 3)
    }
}

// MARK: - Preview Data

private extension [SearchSalon] {

    static let searchPreview: [SearchSalon] = [
        SearchSalon(
            id: "s1",
            name: "Nail bar: Glossy Room",
            address: "вул. Зеленицька, 15 (411), 05-091",
            rating: 4.5,
            distanceKm: 0.8,
            imageUrl: nil,
            latitude: 50.4485,
            longitude: 30.5190,
            isSaved: false
        ),
        SearchSalon(
            id: "s2",
            name: "Beauty Studio Kyiv",
            address: "вул. Франка, 10",
            rating: 4.8,
            distanceKm: 1.2,
            imageUrl: nil,
            latitude: 50.4530,
            longitude: 30.5290,
            isSaved: true
        ),
        SearchSalon(
            id: "s3",
            name: "Brow Bar Kyiv",
            address: "вул. Хрещатик, 22",
            rating: 4.9,
            distanceKm: 2.1,
            imageUrl: nil,
            latitude: 50.4470,
            longitude: 30.5240,
            isSaved: false
        )
    ]
}
