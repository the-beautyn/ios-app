import Combine
import Foundation
import SwiftUI
import MapKit

// MARK: - SearchMapViewModel
//
// State + search orchestration for the map screen. The pure math lives in
// Presentation services: `SearchMapCamera` (regions, zoom spans, visible-strip
// fitting) and `SearchMapClusterBuilder` (pin grid clustering).

@MainActor
final class SearchMapViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        let didTapSalonCard: (_ salonId: String) -> Void
        let didRequireAuth: () -> Void
        let didTapOpenSettings: () -> Void
        /// Opens the text-search sheet with the currently applied state and
        /// the callback that applies the submission back to this screen.
        let didTapSearchField: (_ context: SearchInputContext) -> Void
        /// Opens the sort/price filter sheet with the currently applied state
        /// and the callback that applies the submission back to this screen.
        let didTapSortFilter: (_ context: SearchSortContext) -> Void
        /// Opens the service-type filter sheet with the currently applied
        /// category and the callback that applies the pick back here.
        let didTapServiceTypeFilter: (_ context: ServiceTypeFilterContext) -> Void
    }

    // MARK: - Filter chips

    enum FilterChip {
        case serviceType
        case sort
        case price
    }

    // MARK: - Published State

    @Published private(set) var mapItems: [SearchMapItem] = []
    @Published private(set) var results: [SalonCardModel] = []
    @Published private(set) var totalFound: Int = 0
    /// A background viewport re-search is in flight — drives the small inline
    /// spinner next to the counter, never the full-screen loader.
    @Published private(set) var isRefreshingRegion = false
    @Published var cameraPosition: MapCameraPosition = .region(SearchMapViewModel.defaultCameraRegion)
    @Published var isLocationPermissionAlertPresented = false
    /// The text filter applied from the search sheet — shown in the header
    /// pill and sent with every viewport search until cleared.
    @Published private(set) var appliedQuery: String?
    /// Sort/price filters applied from the sort sheet — sent with every
    /// search until cleared there; non-nil = the matching chip shows its
    /// active border.
    @Published private(set) var appliedSort: SearchSortOption?
    @Published private(set) var appliedPriceMin: Double?
    @Published private(set) var appliedPriceMax: Double?
    /// The service-type filter applied from its sheet — highlights the chip
    /// and is sent with every search until cleared.
    @Published private(set) var appliedCategory: AppCategory?

    var isSortChipActive: Bool { appliedSort != nil }
    var isPriceChipActive: Bool { appliedPriceMin != nil || appliedPriceMax != nil }

    /// Where the map sits before the initial region resolves — mirrors the
    /// use case's final fallback.
    private static let defaultCameraRegion = SearchMapCamera.makeRegion(.kyivFallback)

    // MARK: - Dependencies

    private let transition: Transition
    private let searchSalonsUseCase: any SearchSalonsUseCase
    private let searchPinsUseCase: any SearchPinsUseCase
    private let getSearchFilterOptionsUseCase: any GetSearchFilterOptionsUseCase
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

    /// Where the applied search is centered — kept so the sheet reopens
    /// prefilled with the same place.
    private var appliedLocation: SearchLocation?
    /// The applied day filter — re-sent with every viewport search, kept so
    /// the sheet reopens prefilled with the same day.
    private var appliedDate: Date?
    /// `appliedDate`, ignored once it falls in the past — the map session
    /// can outlive midnight, and a stale day must not keep filtering.
    private var effectiveAppliedDate: Date? {
        appliedDate.flatMap { $0.isBeforeToday ? nil : $0 }
    }
    /// Global sort/price bounds, fetched once on init (they're static) and
    /// handed to the sort sheet via its context. nil = the fetch failed; the
    /// sheet falls back to its built-in defaults.
    private var filterOptions: SearchFilterOptions?

    private var salons: [SearchSalon] = []
    private var currentViewport: SearchViewport?
    private var lastRequestedViewport: SearchViewport?
    private var currentPage = 1
    private var searchTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?
    private var hasStartedInitialLoad = false
    private var isInitialLoadComplete = false
    /// Applied state changed while the initial load was in flight — its
    /// request may already have been built without it, so re-search once
    /// the initial load lands.
    private var needsRefreshAfterInitialLoad = false
    private var isLoadingMore = false
    /// Sheet height as a fraction of the screen, reported by the bottom sheet —
    /// used to focus tapped pins/clusters into the map strip that stays visible.
    private var sheetHeightFraction = 0.6
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
        getSearchFilterOptionsUseCase: any GetSearchFilterOptionsUseCase,
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
        self.getSearchFilterOptionsUseCase = getSearchFilterOptionsUseCase
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

        // The filter-sheet bounds are global and static — one background
        // fetch for the screen's lifetime, off the critical path.
        fetchFilterOptions()

        showLoader()
        defer { hideLoader() }

        let region = SearchMapCamera.makeRegion(await resolveInitialRegionUseCase.execute())
        cameraPosition = .region(region)
        await performSearch(viewport: SearchMapCamera.makeViewport(region))
        isInitialLoadComplete = true

        if needsRefreshAfterInitialLoad {
            needsRefreshAfterInitialLoad = false
            refreshCurrentViewport()
        }
    }

    // MARK: - Map intents

    func mapCameraChanged(_ region: MKCoordinateRegion) {
        // The map settles once on first layout (and after our own programmatic
        // move) — ignore everything until the initial load owns the viewport.
        guard isInitialLoadComplete else { return }

        let viewport = SearchMapCamera.makeViewport(region)
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

    func didTapPin(_ pin: SearchMapPin) {
        // Focus on the tapped salon at street-level zoom — but never zoom OUT
        // if the user is already closer than that.
        focusCamera(
            on: pin.coordinate,
            span: SearchMapCamera.focusSpan(currentViewport: lastRequestedViewport)
        )
    }

    func didTapCluster(_ cluster: SearchMapCluster) {
        // Zoom into the cluster's own bounding box (with padding); the camera
        // settle event then re-searches and re-clusters at the new zoom.
        focusCamera(on: cluster.coordinate, span: SearchMapCamera.clusterZoomSpan(for: cluster))
    }

    func sheetSnapChanged(heightFraction: Double) {
        sheetHeightFraction = heightFraction
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

            self.focusCamera(
                on: CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude),
                span: SearchMapCamera.focusSpan(
                    currentViewport: self.lastRequestedViewport,
                    cappedAt: SearchMapCamera.userLocationFocusSpan
                )
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

    // MARK: - Search sheet

    func didTapSearchField() {
        let mapCenter = (currentViewport ?? lastRequestedViewport).map {
            GeoPoint(latitude: ($0.neLat + $0.swLat) / 2, longitude: ($0.neLng + $0.swLng) / 2)
        }
        transition.didTapSearchField(SearchInputContext(
            initialQuery: appliedQuery,
            initialLocation: appliedLocation,
            initialDate: effectiveAppliedDate,
            mapCenter: mapCenter,
            onApply: { [weak self] submission in
                self?.applySubmission(submission)
            }
        ))
    }

    /// Applies what the search sheet submitted: remembers the query for every
    /// subsequent viewport search and recenters on the picked location.
    private func applySubmission(_ submission: SearchSubmission) {
        appliedQuery = submission.query
        appliedLocation = submission.location
        appliedDate = submission.date

        if let focusPoint = submission.focusPoint {
            // A specific salon was picked — place the camera on it right away
            // (same pin-tap zoom: street level, never zooming out past the
            // current one). This happens behind the opening salon profile, so
            // backing out lands on the salon with no visible camera movement.
            let region = SearchMapCamera.focusedRegion(
                on: CLLocationCoordinate2D(latitude: focusPoint.latitude, longitude: focusPoint.longitude),
                span: SearchMapCamera.focusSpan(currentViewport: lastRequestedViewport),
                sheetHeightFraction: sheetHeightFraction
            )
            cameraPosition = .region(region)
            searchNow(viewport: SearchMapCamera.makeViewport(region))
        } else if let location = submission.location {
            if submission.query == nil {
                // No text filter — let the backend size the area: it picks a
                // base radius from the place kind (city 7 km, address 2, …)
                // and widens it when results are sparse.
                applyLocation(location)
            } else {
                // A text query bypasses the server radius (global match), so
                // there is no effective radius to fit — use the kind's base
                // radius for the camera and search that viewport.
                let region = SearchMapCamera.stripFittedRegion(
                    center: location.point,
                    spanMeters: SearchMapCamera.fallbackRadiusKm(for: location.kind) * 2_000,
                    sheetHeightFraction: sheetHeightFraction
                )
                withAnimation(.easeInOut(duration: 0.3)) {
                    cameraPosition = .region(region)
                }
                // Search the target viewport directly — when the camera
                // already sits there, no settle event fires to do it for us;
                // when it does move, the settle echo is deduped against
                // `lastRequestedViewport`.
                searchNow(viewport: SearchMapCamera.makeViewport(region))
            }
        } else {
            refreshCurrentViewport()
        }
    }

    /// Empty-query location apply: a light center-mode probe discovers the
    /// radius the backend would search (kind base + expand-when-sparse),
    /// the camera is fitted to it, and the regular viewport pipeline runs
    /// on the fitted region — pins, counter, pagination and later pans all
    /// stay in the single viewport paradigm.
    private func applyLocation(_ location: SearchLocation) {
        searchTask?.cancel()
        loadMoreTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self, !Task.isCancelled else { return }
            self.activeRefreshCount += 1
            defer { self.activeRefreshCount -= 1 }

            // The probe carries the price filters too — they change how far
            // the backend widens the radius when matches are sparse.
            let probe = try? await self.searchSalonsUseCase.execute(SearchQuery(
                centerLat: location.point.latitude,
                centerLng: location.point.longitude,
                locationType: location.kind,
                date: self.effectiveAppliedDate,
                priceMin: self.appliedPriceMin,
                priceMax: self.appliedPriceMax,
                appCategoryIds: self.appliedCategory.map { [$0.id] },
                page: 1,
                limit: 1
            ))
            guard !Task.isCancelled else { return }

            let radiusKm = probe?.effectiveRadiusKm
                ?? SearchMapCamera.fallbackRadiusKm(for: location.kind)
            let region = SearchMapCamera.stripFittedRegion(
                center: location.point,
                spanMeters: radiusKm * 2_000,
                sheetHeightFraction: self.sheetHeightFraction
            )
            withAnimation(.easeInOut(duration: 0.3)) {
                self.cameraPosition = .region(region)
            }
            await self.performSearch(viewport: SearchMapCamera.makeViewport(region))
        }
    }

    // MARK: - Filter chips

    func didTapFilterChip(_ chip: FilterChip) {
        switch chip {
        case .serviceType:
            transition.didTapServiceTypeFilter(ServiceTypeFilterContext(
                initialCategory: appliedCategory,
                onApply: { [weak self] category in
                    self?.applyCategory(category)
                }
            ))
        case .sort, .price:
            // The one-time bounds fetch may have failed (e.g. offline start) —
            // retry in the background so the NEXT open gets real bounds; this
            // open proceeds with the sheet's built-in fallback.
            if filterOptions == nil {
                fetchFilterOptions()
            }
            // Both chips open the same sheet — it edits sort and price together.
            transition.didTapSortFilter(SearchSortContext(
                initialSort: appliedSort,
                initialPriceMin: appliedPriceMin,
                initialPriceMax: appliedPriceMax,
                filterOptions: filterOptions,
                onApply: { [weak self] submission in
                    self?.applySortSubmission(submission)
                }
            ))
        }
    }

    private func fetchFilterOptions() {
        Task { [weak self] in
            guard let self else { return }
            self.filterOptions = try? await self.getSearchFilterOptionsUseCase.execute()
        }
    }

    private func applySortSubmission(_ submission: SearchSortSubmission) {
        appliedSort = submission.sort
        appliedPriceMin = submission.priceMin
        appliedPriceMax = submission.priceMax
        refreshCurrentViewport()
    }

    /// Applies what the service-type sheet submitted: remembers the category
    /// for every subsequent search and re-runs the current viewport with it.
    private func applyCategory(_ category: AppCategory?) {
        appliedCategory = category
        refreshCurrentViewport()
    }

    /// Home's category chips land here after the tab switch: drop the text
    /// query and picked location, apply the category, and search around the
    /// user again — same region chain as the initial load (GPS → profile
    /// city → device region → Kyiv).
    func applyCategorySearch(_ category: AppCategory) {
        appliedQuery = nil
        appliedLocation = nil
        appliedDate = nil
        appliedCategory = category
        searchAroundUserRegion()
    }

    /// Home's section headers land here after the tab switch: replace ALL
    /// applied state with the section's search params and search around the
    /// user again. An all-nil preset just clears the filters.
    func applySectionSearch(_ preset: SectionSearchPreset) {
        appliedQuery = preset.query
        appliedLocation = nil
        appliedDate = preset.date
        appliedCategory = preset.category
        appliedSort = preset.sortBy
        appliedPriceMin = preset.priceMin
        appliedPriceMax = preset.priceMax
        searchAroundUserRegion()
    }

    /// Re-centers on the user and re-runs the search with the currently
    /// applied state — same region chain as the initial load (GPS → profile
    /// city → device region → Kyiv).
    private func searchAroundUserRegion() {
        // Before the initial load: its region chain is the same one, so the
        // applied state rides along with `onViewTask`'s own search — unless
        // that search is already in flight with the old state.
        guard isInitialLoadComplete else {
            needsRefreshAfterInitialLoad = hasStartedInitialLoad
            return
        }

        searchTask?.cancel()
        loadMoreTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self, !Task.isCancelled else { return }
            self.activeRefreshCount += 1
            defer { self.activeRefreshCount -= 1 }

            let region = SearchMapCamera.makeRegion(await self.resolveInitialRegionUseCase.execute())
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                self.cameraPosition = .region(region)
            }
            await self.performSearch(viewport: SearchMapCamera.makeViewport(region))
        }
    }

    // MARK: - Search

    private func performSearch(viewport: SearchViewport) async {
        lastRequestedViewport = viewport
        let query = SearchQuery(
            query: appliedQuery,
            centerLat: (viewport.neLat + viewport.swLat) / 2,
            centerLng: (viewport.neLng + viewport.swLng) / 2,
            viewport: viewport,
            date: effectiveAppliedDate,
            sortBy: appliedSort,
            priceMin: appliedPriceMin,
            priceMax: appliedPriceMax,
            appCategoryIds: appliedCategory.map { [$0.id] },
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
            query: appliedQuery,
            centerLat: (viewport.neLat + viewport.swLat) / 2,
            centerLng: (viewport.neLng + viewport.swLng) / 2,
            viewport: viewport,
            date: effectiveAppliedDate,
            sortBy: appliedSort,
            priceMin: appliedPriceMin,
            priceMax: appliedPriceMax,
            appCategoryIds: appliedCategory.map { [$0.id] },
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
        let newItems = SearchMapClusterBuilder.makeItems(pins: searchPins, viewport: viewport)
        withAnimation(.easeInOut(duration: 0.25)) {
            mapItems = newItems
        }
    }

    /// Sets the camera (animated) so `coordinate` lands centered in the
    /// visible strip. Returns the region it set, so callers can search it.
    @discardableResult
    private func focusCamera(on coordinate: CLLocationCoordinate2D, span: MKCoordinateSpan) -> MKCoordinateRegion {
        let region = SearchMapCamera.focusedRegion(
            on: coordinate,
            span: span,
            sheetHeightFraction: sheetHeightFraction
        )
        withAnimation(.easeInOut(duration: 0.3)) {
            cameraPosition = .region(region)
        }
        return region
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
        // Before the initial load completes there is no settled viewport to
        // re-search — but its request may already be in flight with the old
        // applied state, so queue a refresh for when it lands.
        guard isInitialLoadComplete else {
            needsRefreshAfterInitialLoad = hasStartedInitialLoad
            return
        }
        // `currentViewport` is only set by SUCCESSFUL searches — fall back to
        // the last attempted one so applying filters right after a failed
        // load (e.g. backend hiccup) still re-searches instead of silently
        // doing nothing.
        guard let viewport = currentViewport ?? lastRequestedViewport else { return }
        searchNow(viewport: viewport)
    }

    private func searchNow(viewport: SearchViewport) {
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
