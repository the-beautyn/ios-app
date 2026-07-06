import Foundation

// MARK: - SectionSearchPreset

/// Home section-header taps land here after the tab switch: the section's
/// full search parameters, with the category already resolved to the model
/// the service-type chip displays.
struct SectionSearchPreset {
    let query: String?
    let category: AppCategory?
    let sortBy: SearchSortOption?
    let priceMin: Double?
    let priceMax: Double?
    let date: Date?
}
