import Foundation

// MARK: - SalonService

struct SalonService: Identifiable {
    let id: String
    let salonId: String
    let categoryId: String?
    let name: String
    let description: String?
    let durationMinutes: Int
    let price: Double
    let currency: String
    let isActive: Bool
    let sortOrder: Int?
    let workerIds: [String]
    let imageUrls: [String]
}
