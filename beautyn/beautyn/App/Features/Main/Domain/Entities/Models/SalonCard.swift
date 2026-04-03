import Foundation

// MARK: - SalonCard

struct SalonCard: Identifiable {
    let id: String
    let name: String
    let coverImageUrl: String?
    let addressLine: String?
    let city: String?
    let ratingAvg: Double?
    let ratingCount: Int?
    let distanceKm: Double?
    let isSaved: Bool
}
