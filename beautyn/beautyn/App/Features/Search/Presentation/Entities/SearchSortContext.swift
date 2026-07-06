import Foundation

// MARK: - SearchSortSubmission

/// What the sort/price sheet hands back on Застосувати.
struct SearchSortSubmission {
    let sort: SearchSortOption?
    /// nil = the knob was left on its own track edge — that side of the
    /// range filter is omitted.
    let priceMin: Double?
    let priceMax: Double?
}

// MARK: - SearchSortContext

/// Everything the map screen passes when opening the sort/price sheet: the
/// currently applied state (so the sheet reopens prefilled) and the global
/// filter bounds the map fetched once on init. Built by `SearchMapViewModel`,
/// so the coordinator never needs a reference back to it.
struct SearchSortContext {
    let initialSort: SearchSortOption?
    let initialPriceMin: Double?
    let initialPriceMax: Double?
    /// From GET /search/filter-options — nil when the one-time fetch failed
    /// (the sheet then falls back to its built-in defaults).
    let filterOptions: SearchFilterOptions?
    let onApply: (SearchSortSubmission) -> Void
}
