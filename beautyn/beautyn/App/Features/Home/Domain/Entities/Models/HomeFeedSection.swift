import Foundation

// MARK: - HomeFeedSection

struct HomeFeedSection: Identifiable {
    let id: String
    let type: String
    let title: String
    let emoji: String?
    let items: [SalonCard]
    var searchParams: HomeSectionSearchParams? = nil
}

// MARK: - HomeSectionSearchParams

/// The search the backend ran to build this section, in public-search
/// terms — a section tap replays it on the Search tab.
struct HomeSectionSearchParams {
    let query: String?
    let appCategoryIds: [String]?
    let sortBy: SearchSortOption?
    let priceMin: Double?
    let priceMax: Double?
    let date: Date?
}
