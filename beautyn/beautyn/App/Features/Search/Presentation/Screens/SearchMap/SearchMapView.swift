import SwiftUI
import MapKit
import Combine

// MARK: - SearchMapView
//
// Matches Figma "Search" (143:8140) — full-screen map with salon pins, a white
// header (search pill + locate button) and a persistent draggable results
// sheet (peek / medium / large snap positions).

struct SearchMapView: BaseViewProtocol {

    @StateObject var viewModel: SearchMapViewModel
    /// Render tests snapshot the hierarchy with `UIGraphicsImageRenderer`, which
    /// segfaults on a live `MKMapView` (map tiles decode concurrently on
    /// background queues). Tests pass `false` to swap the map for a flat
    /// placeholder — everything else renders as in the app.
    var showsLiveMap: Bool = true
    /// Overridable so render tests can snapshot each snap position.
    var initialSheetSnap: SnapPosition = .medium
    @State private var isSheetPresented = true

    // Sheet snaps: bottom keeps the grabber + filter chips visible above the
    // floating tab bar; top covers the map completely, with the sheet's top
    // edge meeting the bottom of the header (which is layered above the sheet).
    static let bottomSnap: SnapPosition = .height(200)
    static let topSnap: SnapPosition = .fraction(0.87)

    var contentView: some View {
        ZStack(alignment: .top) {
            mapLayer
                .bottomSheet(
                    isPresented: $isSheetPresented,
                    style: .draggable(
                        snapPositions: [Self.bottomSnap, .medium, Self.topSnap],
                        initial: initialSheetSnap
                    ),
                    showDimBackground: false,
                    isDismissible: false,
                    onSnapChange: { viewModel.sheetSnapChanged(heightFraction: $0) }
                ) {
                    sheetContent
                }

            SearchHeaderView(
                query: viewModel.appliedQuery,
                onSearchTap: { viewModel.didTapSearchField() },
                onLocationTap: { viewModel.didTapMapLocationButton() }
            )
        }
        .alert(
            Localization.locationPickerPermissionDenied,
            isPresented: $viewModel.isLocationPermissionAlertPresented
        ) {
            Button(Localization.profileMenuSettings) {
                viewModel.didTapOpenLocationSettings()
            }
            Button(Localization.commonCancel, role: .cancel) {}
        }
    }

    // MARK: - Map

    @ViewBuilder
    private var mapLayer: some View {
        if showsLiveMap {
            liveMap
        } else {
            Color.App.beige2
                .ignoresSafeArea()
        }
    }

    private var liveMap: some View {
        Map(position: $viewModel.cameraPosition) {
            UserAnnotation()

            ForEach(viewModel.mapItems) { item in
                switch item {
                case .pin(let pin):
                    Annotation("", coordinate: pin.coordinate) {
                        Button {
                            viewModel.didTapPin(pin)
                        } label: {
                            pinDot
                        }
                        .buttonStyle(.plain)
                    }
                case .cluster(let cluster):
                    Annotation("", coordinate: cluster.coordinate) {
                        clusterBubble(cluster)
                    }
                }
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .onMapCameraChange(frequency: .onEnd) { context in
            viewModel.mapCameraChanged(context.region)
        }
        .ignoresSafeArea()
    }

    private var pinDot: some View {
        Image(systemName: "smallcircle.filled.circle.fill")
            // Icon size 20 per Figma 143:8142; same recipe as BookingMapView's marker.
            .font(.system(size: 20))
            .foregroundStyle(Color.App.brown1)
            .shadow(color: .black.opacity(0.25), radius: 2)
    }

    private func clusterBubble(_ cluster: SearchMapCluster) -> some View {
        Button {
            viewModel.didTapCluster(cluster)
        } label: {
            Text(cluster.count > 99 ? "99+" : "\(cluster.count)")
                .font(.App.caption1)
                .foregroundStyle(Color.App.white)
                .padding(CGFloat.Spacing.xs)
                // 30pt bubble: reads as "bigger than the 20pt dot" without
                // crowding neighbors; grows with the count text.
                .frame(minWidth: 30, minHeight: 30)
                .background(Circle().fill(Color.App.brown1))
                .shadow(color: .black.opacity(0.25), radius: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Results sheet

    private var sheetContent: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
            filtersRow
            counter
            resultsList
        }
        // Grabber zone (21pt) + sm ≈ 28pt from the sheet top edge, per Figma.
        .padding(.top, CGFloat.Spacing.sm)
        .padding(.horizontal, CGFloat.Spacing.md)
    }

    private var filtersRow: some View {
        HStack(spacing: CGFloat.Spacing.sm) {
            FilterChipView(title: Localization.searchFilterServiceType) {
                viewModel.didTapFilterChip(.serviceType)
            }
            FilterChipView(title: Localization.searchFilterSort) {
                viewModel.didTapFilterChip(.sort)
            }
            FilterChipView(title: Localization.searchFilterPrice) {
                viewModel.didTapFilterChip(.price)
            }
        }
    }

    private var counter: some View {
        HStack(spacing: CGFloat.Spacing.sm) {
            Text(Localization.searchResultsCount(viewModel.totalFound))
                .font(.App.headline)
                .foregroundStyle(Color.App.text)

            if viewModel.isRefreshingRegion {
                ProgressView()
                    .controlSize(.small)
            }
        }
    }

    private var resultsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: CGFloat.Spacing.md) {
                ForEach(viewModel.results) { salon in
                    SalonCardView(
                        salon: salon,
                        style: .fullWidth,
                        onTap: { viewModel.didTapSalonCard(salon.id) },
                        onFavoriteTap: { viewModel.didTapFavorite(salonId: salon.id) }
                    )
                    .onAppear { viewModel.loadMoreIfNeeded(currentItemId: salon.id) }
                    // Reloads cross-fade cards in place instead of sliding rows.
                    .transition(.opacity)
                }
            }
            // Clear the floating Liquid Glass tab bar (~96pt incl. home indicator).
            .padding(.bottom, CGFloat.Spacing.xxxl + CGFloat.Spacing.xl)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    SearchMapView(
        viewModel: SearchMapViewModel(
            transition: .init(
                didTapSalonCard: { _ in },
                didRequireAuth: {},
                didTapOpenSettings: {},
                didTapSearchField: { _ in }
            ),
            searchSalonsUseCase: PreviewSearchSalonsUseCase(),
            searchPinsUseCase: PreviewSearchPinsUseCase(),
            resolveInitialRegionUseCase: PreviewResolveInitialRegionUseCase(),
            getUserLocationUseCase: PreviewGetUserLocationUseCase(),
            observeLocationPermissionUseCase: PreviewObserveLocationPermissionUseCase(),
            saveSalonUseCase: PreviewSaveSalonUseCase(),
            unsaveSalonUseCase: PreviewUnsaveSalonUseCase(),
            savedSalonsEventBus: PreviewSavedSalonsEventBus(),
            sessionManager: SessionManager(keychainService: KeychainServiceImpl(), defaultsService: DefaultsStorageService())
        )
    )
}

private final class PreviewSearchSalonsUseCase: SearchSalonsUseCase {
    func execute(_ query: SearchQuery) async throws -> SearchResults {
        let salons = [
            SearchSalon(
                id: "1",
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
                id: "2",
                name: "Beauty Studio",
                address: "вул. Франка, 10",
                rating: 5.0,
                distanceKm: 1.2,
                imageUrl: nil,
                latitude: 50.4530,
                longitude: 30.5290,
                isSaved: true
            ),
            SearchSalon(
                id: "3",
                name: "Brow Bar Kyiv",
                address: "вул. Хрещатик, 22",
                rating: 4.8,
                distanceKm: 2.0,
                imageUrl: nil,
                latitude: 50.4470,
                longitude: 30.5240,
                isSaved: false
            )
        ]
        return SearchResults(items: salons, page: 1, limit: 20, total: 1576)
    }
}

private final class PreviewSearchPinsUseCase: SearchPinsUseCase {
    func execute(_ query: SearchQuery) async throws -> [SearchPin] {
        [
            SearchPin(id: "1", latitude: 50.4485, longitude: 30.5190),
            SearchPin(id: "2", latitude: 50.4530, longitude: 30.5290),
            SearchPin(id: "3", latitude: 50.4470, longitude: 30.5240),
            SearchPin(id: "p4", latitude: 50.4555, longitude: 30.5155),
            SearchPin(id: "p5", latitude: 50.4430, longitude: 30.5320)
        ]
    }
}

private final class PreviewResolveInitialRegionUseCase: ResolveInitialSearchRegionUseCase {
    func execute() async -> SearchRegion { .kyivFallback }
}

private final class PreviewGetUserLocationUseCase: GetUserLocationUseCase {
    func execute() async -> GeoPoint? { nil }
}

private final class PreviewObserveLocationPermissionUseCase: ObserveLocationPermissionUseCase {
    func execute() -> AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
    }
}

private final class PreviewSaveSalonUseCase: SaveSalonUseCase {
    func execute(salonId: String) async throws {}
}

private final class PreviewUnsaveSalonUseCase: UnsaveSalonUseCase {
    func execute(salonId: String) async throws {}
}

private final class PreviewSavedSalonsEventBus: SavedSalonsEventBus {
    var changes: AnyPublisher<SavedSalonChange, Never> { Empty().eraseToAnyPublisher() }
    func notify(_ change: SavedSalonChange) {}
}
#endif
