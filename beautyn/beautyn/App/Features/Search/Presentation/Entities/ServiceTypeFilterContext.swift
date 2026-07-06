import Foundation

// MARK: - ServiceTypeFilterContext

/// Everything the map screen passes when opening the service-type filter
/// sheet: the applied category (so the sheet reopens preselected) and the
/// callback fired on Застосувати. Built by `SearchMapViewModel`, so the
/// coordinator never needs a reference back to it.
struct ServiceTypeFilterContext {
    /// The full model (not just the id) so the sheet can hand it back on
    /// Застосувати even before its own category list finishes loading.
    let initialCategory: AppCategory?
    /// `nil` means the user applied with nothing selected — remove the filter.
    let onApply: (AppCategory?) -> Void
}
