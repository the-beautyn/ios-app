import Foundation

// MARK: - SalonRepository

protocol SalonRepository {
    /// `isFromSearch` marks the fetch as coming from the search flow — the
    /// backend records a search-history visit for the authenticated user.
    func getSalon(id: String, isFromSearch: Bool) async throws -> Salon
    func getShare(id: String) async throws -> SalonShare
}
