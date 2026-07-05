import Foundation

// MARK: - SearchSubmission

/// What the search sheet hands back to the map screen on the keyboard
/// "Search" key: an optional text filter and an optional place to center on.
struct SearchSubmission {
    let query: String?
    let location: SearchLocation?
    /// Set when a specific salon was picked — the map zooms straight to it
    /// (pin-tap style) instead of the location region.
    var focusPoint: GeoPoint? = nil
}

// MARK: - SearchInputContext

/// Everything the map screen passes when opening the search sheet: the
/// currently applied state (so the sheet reopens prefilled) and the callback
/// the sheet fires on submit. Built by `SearchMapViewModel`, so the
/// coordinator never needs a reference back to it.
struct SearchInputContext {
    let initialQuery: String?
    let initialLocation: SearchLocation?
    /// What the map is currently looking at — ranks the sheet's type-ahead
    /// results by distance when no location is picked yet.
    let mapCenter: GeoPoint?
    let onApply: (SearchSubmission) -> Void
}
