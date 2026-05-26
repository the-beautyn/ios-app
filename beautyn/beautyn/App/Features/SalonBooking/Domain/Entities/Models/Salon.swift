import Foundation

// MARK: - Salon

struct Salon: Identifiable {
    let id: String
    let name: String
    let addressLine: String?
    let city: String?
    let phone: String?
    let description: String?
    let coverImageUrl: String?
    let imageUrls: [String]
    let ratingAvg: Double?
    let ratingCount: Int
    let workingSchedule: String?
    let topMastersTag: String?
    let isSaved: Bool
    let services: [SalonService]
    let workers: [SalonWorker]
    let categories: [SalonCategory]
}
