import Foundation

// MARK: - SavedSalonsRepository

protocol SavedSalonsRepository {
    func list(query: String?, page: Int?, limit: Int?) async throws -> SavedSalonsList
    func save(salonId: String) async throws
    func unsave(salonId: String) async throws
}
