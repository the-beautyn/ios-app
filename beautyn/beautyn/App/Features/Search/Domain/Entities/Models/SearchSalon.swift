import Foundation

// MARK: - SearchSalon

struct SearchSalon: Identifiable, Equatable {
    let id: String
    let name: String
    let address: String
    let rating: Double?
    let distanceKm: Double?
    let imageUrl: String?
    let latitude: Double?
    let longitude: Double?
    var isSaved: Bool
}

// MARK: - SearchResults

struct SearchResults: Equatable {
    let items: [SearchSalon]
    let page: Int
    let limit: Int
    let total: Int
    /// The radius the backend actually searched in center mode (after its
    /// expand-when-sparse loop) — absent for viewport/global searches.
    var effectiveRadiusKm: Double? = nil
}

// MARK: - SearchPin

/// A map-only search match: every salon in the viewport, not just the
/// current list page.
struct SearchPin: Identifiable, Equatable {
    let id: String
    let latitude: Double
    let longitude: Double
}

// MARK: - SearchViewport

/// Geographic rectangle (NE / SW corners) matching the backend's strict
/// viewport filter. Kept MapKit-free so the domain layer stays framework-agnostic.
struct SearchViewport: Equatable {
    let neLat: Double
    let neLng: Double
    let swLat: Double
    let swLng: Double

    var latSpan: Double { neLat - swLat }
    var lngSpan: Double { neLng - swLng }

    /// True when both rectangles differ by less than `tolerance` × their own
    /// span on every edge — used to swallow map-camera jitter and the initial
    /// aspect-ratio settle event.
    func isApproximatelyEqual(to other: SearchViewport, tolerance: Double) -> Bool {
        let latEpsilon = abs(latSpan) * tolerance
        let lngEpsilon = abs(lngSpan) * tolerance
        return abs(neLat - other.neLat) < latEpsilon
            && abs(swLat - other.swLat) < latEpsilon
            && abs(neLng - other.neLng) < lngEpsilon
            && abs(swLng - other.swLng) < lngEpsilon
    }
}

// MARK: - SearchSortOption

/// Server sort keys for POST /search — mirrors the backend's SortOptionEnum.
/// The filter sheet surfaces four of them; `priceDesc` stays contract-only.
enum SearchSortOption: String {
    case distance
    case ratingDesc = "rating_desc"
    case priceAsc = "price_asc"
    case priceDesc = "price_desc"
    case popular
}

// MARK: - SearchFilterOptions

/// Static bounds for the sort/price filter sheet, from
/// GET /search/filter-options — fetched once per screen lifetime.
struct SearchFilterOptions: Equatable {
    /// Sort keys the backend currently accepts.
    let sortOptions: [SearchSortOption]
    /// Price-range track start: the cheapest service anywhere (грн, rounded
    /// down); nil when no salon has price data.
    let minPrice: Double?
    /// Price-range track end: the priciest service anywhere (грн, rounded
    /// up); nil when no salon has price data.
    let maxPrice: Double?
}

// MARK: - SearchQuery

struct SearchQuery {
    var query: String?
    var centerLat: Double?
    var centerLng: Double?
    var viewport: SearchViewport?
    /// What kind of place the center is — the backend picks its base search
    /// radius from it (city 7 km, address 2 km, …) in center mode.
    var locationType: SearchLocationKind?
    /// Keeps only salons open on that day (weekday open-hours filter).
    var date: Date?
    var sortBy: SearchSortOption?
    /// Range-overlap price filter: the salon's [min, max] price span must
    /// intersect [priceMin, priceMax] — i.e. it offers at least one service
    /// in the requested budget (грн).
    var priceMin: Double?
    var priceMax: Double?
    /// Restricts matches to salons mapped to any of these app categories.
    var appCategoryIds: [String]?
    var page: Int = 1
    var limit: Int = 20
}
