import Combine
import MapKit
import SwiftUI
import XCTest
@testable import beautyn

// MARK: - SearchViewRenderTests
//
// Renders the actual SearchView with mock data to a PNG for visual verification.
// The mock use case returns preview salons, which flow through the normal
// ViewModel lifecycle (onViewTask → resolve region → performSearch → apply).
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
//     -only-testing:beautynTests/SearchViewRenderTests

@MainActor
final class SearchViewRenderTests: XCTestCase {

    func testRenderSearch() async throws {
        let viewModel = makeViewModel()
        // showsLiveMap: false — snapshotting a live MKMapView segfaults in the
        // render harness (concurrent tile decode during UIGraphicsImageRenderer).
        let view = SearchView(viewModel: viewModel, showsLiveMap: false)
        try await ViewRenderer.render(view, name: "search")
    }

    func testRenderSearchSheetBottom() async throws {
        let viewModel = makeViewModel()
        let view = SearchView(viewModel: viewModel, showsLiveMap: false, initialSheetSnap: SearchView.bottomSnap)
        try await ViewRenderer.render(view, name: "search_sheet_bottom")
    }

    func testRenderSearchSheetTop() async throws {
        let viewModel = makeViewModel()
        let view = SearchView(viewModel: viewModel, showsLiveMap: false, initialSheetSnap: SearchView.topSnap)
        try await ViewRenderer.render(view, name: "search_sheet_top")
    }

    // MARK: - Helpers

    private func makeViewModel() -> SearchViewModel {
        SearchViewModel(
            transition: .init(
                didTapSalonCard: { _ in },
                didRequireAuth: {},
                didTapOpenSettings: {}
            ),
            searchSalonsUseCase: MockSearchSalonsUseCase(),
            searchPinsUseCase: MockSearchPinsUseCase(),
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

// MARK: - SearchClusteringTests

@MainActor
final class SearchClusteringTests: XCTestCase {

    private let viewport = SearchViewport(neLat: 50.5, neLng: 30.6, swLat: 50.4, swLng: 30.4)

    func testLonePinsStaySingles() {
        // Opposite corners of the viewport — far beyond one grid cell apart.
        let pins = [
            SearchPin(id: "a", latitude: 50.41, longitude: 30.41),
            SearchPin(id: "b", latitude: 50.49, longitude: 30.59),
        ]
        let items = SearchViewModel.makeMapItems(pins: pins, viewport: viewport)

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
        let items = SearchViewModel.makeMapItems(pins: pins, viewport: viewport)

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
        let items = SearchViewModel.makeMapItems(pins: pins, viewport: viewport)

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
        let items = SearchViewModel.makeMapItems(pins: pins, viewport: viewport)

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
