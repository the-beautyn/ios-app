import Foundation

// MARK: - SalonCategory

struct SalonCategory: Identifiable {
    let id: String
    let salonId: String
    let name: String
    let color: String?
    let sortOrder: Int?
    let serviceIds: [String]
}
