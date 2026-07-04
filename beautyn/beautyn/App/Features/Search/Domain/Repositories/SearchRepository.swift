import Foundation

// MARK: - SearchRepository

protocol SearchRepository {
    func search(_ query: SearchQuery) async throws -> SearchResults
    /// All matching pins for the query's viewport (capped server-side),
    /// independent of list pagination.
    func pins(_ query: SearchQuery) async throws -> [SearchPin]
}
