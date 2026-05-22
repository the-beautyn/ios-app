import Foundation

// MARK: - SavedSalon

struct SavedSalon: Identifiable {
    let id: String
    let salonId: String
    let salonName: String
    let coverImageUrl: String?
    let addressLine: String?
    let city: String?
    let ratingAvg: Double?
    let ratingCount: Int?
    let savedAt: Date
}
