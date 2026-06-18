import Foundation

// MARK: - SalonRepository

protocol SalonRepository {
    func getSalon(id: String) async throws -> Salon
    func getShare(id: String) async throws -> SalonShare
}
