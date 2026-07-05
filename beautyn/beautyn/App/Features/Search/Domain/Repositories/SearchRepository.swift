import Foundation

// MARK: - SearchRepository

protocol SearchRepository {
    func search(_ query: SearchQuery) async throws -> SearchResults
    /// All matching pins for the query's viewport (capped server-side),
    /// independent of list pagination.
    func pins(_ query: SearchQuery) async throws -> [SearchPin]
    /// Static filter-sheet bounds: sort keys + the global price range.
    func filterOptions() async throws -> SearchFilterOptions

    /// The user's visited-salon history, most recent first. Requires auth.
    func history(limit: Int) async throws -> [SearchHistoryItem]
    /// Removes the whole history. Requires auth.
    func clearHistory() async throws
    /// Removes a single entry by its history row id. Requires auth.
    func deleteHistoryItem(id: String) async throws
}
