import Combine
import Foundation
import SwiftUI
import MapKit

// MARK: - SearchViewModel

@MainActor
final class SearchViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        let didTapSalonCard: (_ salonId: String) -> Void
        let didRequireAuth: () -> Void
        let didTapOpenSettings: () -> Void
    }

    // MARK: - Filter chips (placeholder taps for now)

    enum FilterChip {
        case serviceType
        case sort
        case price
    }

    // MARK: - Map Entities (Presentation)

    struct MapPin: Identifiable, Equatable {
        let id: String
        let coordinate: CLLocationCoordinate2D

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
                && lhs.coordinate.latitude == rhs.coordinate.latitude
                && lhs.coordinate.longitude == rhs.coordinate.longitude
        }
    }

    struct MapCluster: Identifiable, Equatable {
        let id: String
        let coordinate: CLLocationCoordinate2D
        let count: Int
        /// Bounding box of the clustered pins — the tap-to-zoom target.
        let minLat: Double
        let maxLat: Double
        let minLng: Double
        let maxLng: Double

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id && lhs.count == rhs.count
                && lhs.coordinate.latitude == rhs.coordinate.latitude
                && lhs.coordinate.longitude == rhs.coordinate.longitude
        }
    }

    enum MapItem: Identifiable, Equatable {
        case pin(MapPin)
        case cluster(MapCluster)

        var id: String {
            switch self {
            case .pin(let pin): return pin.id
            case .cluster(let cluster): return cluster.id
            }
        }
    }

    // MARK: - Published State

    @Published private(set) var mapItems: [MapItem] = []
    @Published private(set) var results: [SalonCardModel] = []
    @Published private(set) var totalFound: Int = 0
    /// A background viewport re-search is in flight — drives the small inline
    /// spinner next to the counter, never the full-screen loader.
    @Published private(set) var isRefreshingRegion = false
    @Published var cameraPosition: MapCameraPosition = .region(SearchViewModel.defaultCameraRegion)
    @Published var isLocationPermissionAlertPresented = false

    /// Where the map sits before the initial region resolves — mirrors the
    /// use case's final fallback.
    private static let defaultCameraRegion = makeRegion(.kyivFallback)

    // MARK: - Dependencies

    private let transition: Transition
    private let searchSalonsUseCase: any SearchSalonsUseCase
    private let searchPinsUseCase: any SearchPinsUseCase
    private let resolveInitialRegionUseCase: any ResolveInitialSearchRegionUseCase
    private let getUserLocationUseCase: any GetUserLocationUseCase
    private let observeLocationPermissionUseCase: any ObserveLocationPermissionUseCase
    private let saveSalonUseCase: any SaveSalonUseCase
    private let unsaveSalonUseCase: any UnsaveSalonUseCase
    private let savedSalonsEventBus: any SavedSalonsEventBus
    private let sessionManager: SessionManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Search state

    private static let pageSize = 20
    /// Camera deltas below this fraction of the viewport span are jitter (or the
    /// echo of our own programmatic camera move), not a pan — no re-search.
    private static let viewportTolerance = 0.1
    private static let panDebounce: Duration = .milliseconds(500)

    private var salons: [SearchSalon] = []
    private var currentViewport: SearchViewport?
    private var lastRequestedViewport: SearchViewport?
    private var currentPage = 1
    private var searchTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?
    private var hasStartedInitialLoad = false
    private var isInitialLoadComplete = false
    private var isLoadingMore = false
    /// Sheet height as a fraction of the screen, reported by the bottom sheet —
    /// used to focus tapped pins/clusters into the map strip that stays visible.
    private var sheetHeightFraction = 0.6
    /// Approximate screen fraction covered by the header (safe area + content).
    private static let headerHeightFraction = 0.13
    /// Zoom used when centering on the user (~3 km across).
    private static let userLocationFocusSpan = 0.03
    /// Location access is denied/restricted — tapping the map's location
    /// button then offers Settings instead of locating.
    private var isLocationPermissionDenied = false
    private var locateUserTask: Task<Void, Never>?
    /// Overlapping silent refreshes each raise/lower this; the inline spinner
    /// shows while any of them is still in flight.
    private var activeRefreshCount = 0 {
        didSet { isRefreshingRegion = activeRefreshCount > 0 }
    }

    // MARK: - Init

    init(
        transition: Transition,
        searchSalonsUseCase: any SearchSalonsUseCase,
        searchPinsUseCase: any SearchPinsUseCase,
        resolveInitialRegionUseCase: any ResolveInitialSearchRegionUseCase,
        getUserLocationUseCase: any GetUserLocationUseCase,
        observeLocationPermissionUseCase: any ObserveLocationPermissionUseCase,
        saveSalonUseCase: any SaveSalonUseCase,
        unsaveSalonUseCase: any UnsaveSalonUseCase,
        savedSalonsEventBus: any SavedSalonsEventBus,
        sessionManager: SessionManager
    ) {
        self.transition = transition
        self.searchSalonsUseCase = searchSalonsUseCase
        self.searchPinsUseCase = searchPinsUseCase
        self.resolveInitialRegionUseCase = resolveInitialRegionUseCase
        self.getUserLocationUseCase = getUserLocationUseCase
        self.observeLocationPermissionUseCase = observeLocationPermissionUseCase
        self.saveSalonUseCase = saveSalonUseCase
        self.unsaveSalonUseCase = unsaveSalonUseCase
        self.savedSalonsEventBus = savedSalonsEventBus
        self.sessionManager = sessionManager
        super.init()
        observeAuthState()
        observeSavedSalonsBus()
        observeLocationPermission()
    }

    // MARK: - Lifecycle

    override func onViewTask() async {
        // `.task` re-fires on every tab re-selection — the initial load runs once.
        guard !hasStartedInitialLoad else { return }
        hasStartedInitialLoad = true

        showLoader()
        defer { hideLoader() }

        let region = Self.makeRegion(await resolveInitialRegionUseCase.execute())
        cameraPosition = .region(region)
        await performSearch(viewport: Self.makeViewport(region))
        isInitialLoadComplete = true
    }

    // MARK: - Map intents

    func mapCameraChanged(_ region: MKCoordinateRegion) {
        // The map settles once on first layout (and after our own programmatic
        // move) — ignore everything until the initial load owns the viewport.
        guard isInitialLoadComplete else { return }

        let viewport = Self.makeViewport(region)
        if let last = lastRequestedViewport,
           viewport.isApproximatelyEqual(to: last, tolerance: Self.viewportTolerance) {
            return
        }

        searchTask?.cancel()
        loadMoreTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: Self.panDebounce)
            guard let self, !Task.isCancelled else { return }
            self.activeRefreshCount += 1
            defer { self.activeRefreshCount -= 1 }
            await self.performSearch(viewport: viewport)
        }
    }

    // MARK: - List intents

    func didTapSalonCard(_ salonId: String) {
        transition.didTapSalonCard(salonId)
    }

    func loadMoreIfNeeded(currentItemId: String) {
        guard isInitialLoadComplete,
              !isLoadingMore,
              salons.count < totalFound,
              let index = salons.firstIndex(where: { $0.id == currentItemId }),
              index >= salons.count - 3 else { return }

        isLoadingMore = true
        loadMoreTask = Task { [weak self] in
            guard let self else { return }
            defer { self.isLoadingMore = false }
            await self.loadNextPage()
        }
    }

    func didTapFavorite(salonId: String) {
        guard sessionManager.isAuthenticated else {
            transition.didRequireAuth()
            return
        }
        guard let index = results.firstIndex(where: { $0.id == salonId }) else { return }
        let wasFavorited = results[index].isFavorited
        setFavorited(!wasFavorited, salonId: salonId)

        Task { [weak self] in
            guard let self else { return }
            do {
                if wasFavorited {
                    try await self.unsaveSalonUseCase.execute(salonId: salonId)
                } else {
                    try await self.saveSalonUseCase.execute(salonId: salonId)
                }
            } catch {
                self.setFavorited(wasFavorited, salonId: salonId)
                self.showError(error)
            }
        }
    }

    // MARK: - My location

    /// The map's locate button: center-and-zoom on the user's position, or
    /// offer Settings when location access is denied.
    func didTapMapLocationButton() {
        guard !isLocationPermissionDenied else {
            isLocationPermissionAlertPresented = true
            return
        }
        locateUserTask?.cancel()
        locateUserTask = Task { [weak self] in
            guard let self, let point = await self.getUserLocationUseCase.execute(),
                  !Task.isCancelled else { return }

            let currentLatSpan = self.lastRequestedViewport.map { abs($0.latSpan) } ?? Self.userLocationFocusSpan
            let currentLngSpan = self.lastRequestedViewport.map { abs($0.lngSpan) } ?? Self.userLocationFocusSpan
            let span = MKCoordinateSpan(
                latitudeDelta: min(currentLatSpan, Self.userLocationFocusSpan),
                longitudeDelta: min(currentLngSpan, Self.userLocationFocusSpan)
            )
            self.focusCamera(
                on: CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude),
                span: span
            )
        }
    }

    func didTapOpenLocationSettings() {
        transition.didTapOpenSettings()
    }

    private func observeLocationPermission() {
        observeLocationPermissionUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDenied in
                self?.isLocationPermissionDenied = isDenied
            }
            .store(in: &cancellables)
    }

    // MARK: - Placeholder intents (implemented in later iterations)

    func didTapSearchField() {}

    func didTapLocation() {}

    func didTapFilterChip(_ chip: FilterChip) {}

    // MARK: - Search

    private func performSearch(viewport: SearchViewport) async {
        lastRequestedViewport = viewport
        let query = SearchQuery(
            centerLat: (viewport.neLat + viewport.swLat) / 2,
            centerLng: (viewport.neLng + viewport.swLng) / 2,
            viewport: viewport,
            page: 1,
            limit: Self.pageSize
        )
        do {
            // The map pins request covers ALL viewport matches (capped
            // server-side) and runs alongside the first list page.
            async let pinsRequest = searchPinsUseCase.execute(query)
            let searchResults = try await searchSalonsUseCase.execute(query)
            // Cancellation is cooperative — the HTTP request itself is not
            // aborted, so a superseded response is simply dropped here.
            guard !Task.isCancelled else { return }
            currentViewport = viewport
            currentPage = 1
            apply(searchResults, replace: true)

            // Pins are best-effort: fall back to the page's own coordinates.
            let searchPins = (try? await pinsRequest) ?? Self.fallbackPins(from: searchResults.items)
            guard !Task.isCancelled else { return }
            applyPins(searchPins)
        } catch is CancellationError {
            // Superseded by a newer pan — ignore.
        } catch {
            guard !Task.isCancelled else { return }
            showError(error)
        }
    }

    private func loadNextPage() async {
        guard let viewport = currentViewport else { return }
        let query = SearchQuery(
            centerLat: (viewport.neLat + viewport.swLat) / 2,
            centerLng: (viewport.neLng + viewport.swLng) / 2,
            viewport: viewport,
            page: currentPage + 1,
            limit: Self.pageSize
        )
        do {
            let nextPage = try await searchSalonsUseCase.execute(query)
            guard !Task.isCancelled else { return }
            currentPage += 1
            apply(nextPage, replace: false)
        } catch is CancellationError {
            // The viewport changed while the page was loading — ignore.
        } catch {
            guard !Task.isCancelled else { return }
            showError(error)
        }
    }

    private func apply(_ searchResults: SearchResults, replace: Bool) {
        if replace {
            salons = searchResults.items
        } else {
            // Server pages can shift between requests — drop duplicates so
            // Identifiable stays unique in ForEach.
            let existingIds = Set(salons.map(\.id))
            salons += searchResults.items.filter { !existingIds.contains($0.id) }
        }
        totalFound = searchResults.total

        let newResults = salons.map(Self.makeCardModel)
        withAnimation(.easeInOut(duration: 0.25)) {
            results = newResults
        }
    }

    private func applyPins(_ searchPins: [SearchPin]) {
        guard let viewport = currentViewport ?? lastRequestedViewport else { return }
        let newItems = Self.makeMapItems(pins: searchPins, viewport: viewport)
        withAnimation(.easeInOut(duration: 0.25)) {
            mapItems = newItems
        }
    }

    // MARK: - Clustering

    /// Grid cells across the viewport — ≈50 pt per cell on a phone-width map,
    /// so pins closer than a fingertip merge into one bubble.
    private static let clusterGridDivisions = 8.0
    /// Cells with fewer pins than this stay individual dots — small groups
    /// read better as dots than as a tiny numbered bubble.
    private static let minClusterSize = 5
    /// Never zoom a tapped cluster tighter than this (~500 m).
    private static let minClusterZoomSpan = 0.005

    /// Buckets pins into a viewport-relative grid: lone pins render as dots,
    /// denser cells as count bubbles. Keeps the annotation count bounded by
    /// the grid size regardless of how many pins the server returns.
    static func makeMapItems(pins: [SearchPin], viewport: SearchViewport) -> [MapItem] {
        let cellLat = max(abs(viewport.latSpan), 0.000001) / clusterGridDivisions
        let cellLng = max(abs(viewport.lngSpan), 0.000001) / clusterGridDivisions

        var buckets: [String: [SearchPin]] = [:]
        for pin in pins {
            let row = Int(floor((pin.latitude - viewport.swLat) / cellLat))
            let column = Int(floor((pin.longitude - viewport.swLng) / cellLng))
            buckets["\(row):\(column)", default: []].append(pin)
        }

        return buckets
            .flatMap { key, cellPins -> [MapItem] in
                if cellPins.count < minClusterSize {
                    return cellPins.map { pin in
                        .pin(MapPin(
                            id: pin.id,
                            coordinate: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                        ))
                    }
                }
                let latitudes = cellPins.map(\.latitude)
                let longitudes = cellPins.map(\.longitude)
                return [.cluster(MapCluster(
                    id: "cluster-\(key)",
                    coordinate: CLLocationCoordinate2D(
                        latitude: latitudes.reduce(0, +) / Double(cellPins.count),
                        longitude: longitudes.reduce(0, +) / Double(cellPins.count)
                    ),
                    count: cellPins.count,
                    minLat: latitudes.min() ?? 0,
                    maxLat: latitudes.max() ?? 0,
                    minLng: longitudes.min() ?? 0,
                    maxLng: longitudes.max() ?? 0
                ))]
            }
            .sorted { $0.id < $1.id }
    }

    func didTapPin(_ pin: MapPin) {
        // Focus on the tapped salon at street-level zoom — but never zoom OUT
        // if the user is already closer than that.
        let currentLatSpan = lastRequestedViewport.map { abs($0.latSpan) } ?? Self.minClusterZoomSpan
        let currentLngSpan = lastRequestedViewport.map { abs($0.lngSpan) } ?? Self.minClusterZoomSpan
        let span = MKCoordinateSpan(
            latitudeDelta: min(currentLatSpan, Self.minClusterZoomSpan),
            longitudeDelta: min(currentLngSpan, Self.minClusterZoomSpan)
        )
        focusCamera(on: pin.coordinate, span: span)
    }

    func didTapCluster(_ cluster: MapCluster) {
        // Zoom into the cluster's own bounding box (with padding); the camera
        // settle event then re-searches and re-clusters at the new zoom.
        let span = MKCoordinateSpan(
            latitudeDelta: max((cluster.maxLat - cluster.minLat) * 1.6, Self.minClusterZoomSpan),
            longitudeDelta: max((cluster.maxLng - cluster.minLng) * 1.6, Self.minClusterZoomSpan)
        )
        focusCamera(on: cluster.coordinate, span: span)
    }

    func sheetSnapChanged(heightFraction: Double) {
        sheetHeightFraction = heightFraction
    }

    /// Moves the camera so `coordinate` lands centered in the map strip that
    /// remains VISIBLE between the header and the results sheet — not in the
    /// middle of the full screen, where the sheet would cover it.
    private func focusCamera(on coordinate: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        let visibleCenterFraction = (Self.headerHeightFraction + (1 - sheetHeightFraction)) / 2
        let latitudeOffset = (0.5 - visibleCenterFraction) * span.latitudeDelta
        let center = CLLocationCoordinate2D(
            latitude: coordinate.latitude - latitudeOffset,
            longitude: coordinate.longitude
        )
        withAnimation(.easeInOut(duration: 0.3)) {
            cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
    }

    private static func fallbackPins(from items: [SearchSalon]) -> [SearchPin] {
        items.compactMap { salon in
            guard let latitude = salon.latitude, let longitude = salon.longitude else { return nil }
            return SearchPin(id: salon.id, latitude: latitude, longitude: longitude)
        }
    }

    // MARK: - Favorites sync

    private func observeSavedSalonsBus() {
        savedSalonsEventBus.changes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] change in
                self?.setFavorited(change.isSaved, salonId: change.salonId)
            }
            .store(in: &cancellables)
    }

    private func setFavorited(_ isFavorited: Bool, salonId: String) {
        if let index = results.firstIndex(where: { $0.id == salonId }) {
            results[index].isFavorited = isFavorited
        }
        if let index = salons.firstIndex(where: { $0.id == salonId }) {
            salons[index].isSaved = isFavorited
        }
    }

    // Re-run the current viewport silently when the auth state flips so the
    // per-salon `is_saved` flags reflect the new session.
    private func observeAuthState() {
        sessionManager.isAuthenticatedPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshCurrentViewport()
            }
            .store(in: &cancellables)
    }

    private func refreshCurrentViewport() {
        guard isInitialLoadComplete, let viewport = currentViewport else { return }
        searchTask?.cancel()
        loadMoreTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self, !Task.isCancelled else { return }
            self.activeRefreshCount += 1
            defer { self.activeRefreshCount -= 1 }
            await self.performSearch(viewport: viewport)
        }
    }

    // MARK: - Mapping

    private static func makeRegion(_ region: SearchRegion) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: region.center.latitude,
                longitude: region.center.longitude
            ),
            latitudinalMeters: region.spanMeters,
            longitudinalMeters: region.spanMeters
        )
    }

    private static func makeViewport(_ region: MKCoordinateRegion) -> SearchViewport {
        SearchViewport(
            neLat: region.center.latitude + region.span.latitudeDelta / 2,
            neLng: region.center.longitude + region.span.longitudeDelta / 2,
            swLat: region.center.latitude - region.span.latitudeDelta / 2,
            swLng: region.center.longitude - region.span.longitudeDelta / 2
        )
    }

    private static func makeCardModel(_ salon: SearchSalon) -> SalonCardModel {
        SalonCardModel(
            id: salon.id,
            name: salon.name,
            address: salon.address,
            imageURL: salon.imageUrl.flatMap(URL.init(string:)),
            rating: salon.rating,
            tag: nil,
            isFavorited: salon.isSaved
        )
    }
}
