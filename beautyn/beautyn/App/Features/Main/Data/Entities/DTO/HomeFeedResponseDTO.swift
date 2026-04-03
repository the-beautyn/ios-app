import Foundation

// MARK: - HomeFeedResponseDTO

struct HomeFeedResponseDTO: Decodable {
    let categories: [AppCategoryDTO]
    let nextBooking: HomeFeedNextBookingDTO?
    let savedSalons: [SavedSalonItemDTO]?
    let sections: [HomeFeedSectionDTO]
}

// MARK: - AppCategoryDTO

struct AppCategoryDTO: Decodable {
    let id: String
    let slug: String
    let name: String
    let keywords: [String]?
    let sortOrder: Int?
    let imageUrl: String?
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
}

// MARK: - HomeFeedNextBookingDTO

struct HomeFeedNextBookingDTO: Decodable {
    let bookingId: String
    let salonId: String
    let salonName: String
    let salonCoverImageUrl: String?
    let salonAddressLine: String?
    let datetime: String
    let endDatetime: String?
    let totalPriceCents: Int?
    let durationMinutes: Int?
}

// MARK: - HomeFeedSectionDTO

struct HomeFeedSectionDTO: Decodable {
    let id: String
    let type: String
    let title: String
    let emoji: String?
    let items: [HomeFeedSalonCardDTO]
}

// MARK: - HomeFeedSalonCardDTO

struct HomeFeedSalonCardDTO: Decodable {
    let id: String
    let name: String
    let coverImageUrl: String?
    let addressLine: String?
    let city: String?
    let ratingAvg: Double?
    let ratingCount: Int?
    let distanceKm: Double?
    let isSaved: Bool?
}

// MARK: - SavedSalonItemDTO

struct SavedSalonItemDTO: Decodable {
    let id: String
    let salonId: String
    let salonName: String
    let coverImageUrl: String?
    let addressLine: String?
    let city: String?
    let ratingAvg: Double?
    let ratingCount: Int?
    let savedAt: String
}
