import Foundation

// MARK: - HomeFeedResponseDTO

struct HomeFeedResponseDTO: Decodable {
    let categories: [AppCategoryDTO]
    let nextBooking: HomeFeedNextBookingDTO?
    let savedSalons: [SavedSalonItemDTO]?
    let sections: [HomeFeedSectionDTO]

    enum CodingKeys: String, CodingKey {
        case categories
        case nextBooking = "next_booking"
        case savedSalons = "saved_salons"
        case sections
    }
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

    enum CodingKeys: String, CodingKey {
        case id
        case slug
        case name
        case keywords
        case sortOrder = "sort_order"
        case imageUrl = "image_url"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
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

    enum CodingKeys: String, CodingKey {
        case bookingId = "booking_id"
        case salonId = "salon_id"
        case salonName = "salon_name"
        case salonCoverImageUrl = "salon_cover_image_url"
        case salonAddressLine = "salon_address_line"
        case datetime
        case endDatetime = "end_datetime"
        case totalPriceCents = "total_price_cents"
        case durationMinutes = "duration_minutes"
    }
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

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case coverImageUrl = "cover_image_url"
        case addressLine = "address_line"
        case city
        case ratingAvg = "rating_avg"
        case ratingCount = "rating_count"
        case distanceKm = "distance_km"
        case isSaved = "is_saved"
    }
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

    enum CodingKeys: String, CodingKey {
        case id
        case salonId = "salon_id"
        case salonName = "salon_name"
        case coverImageUrl = "cover_image_url"
        case addressLine = "address_line"
        case city
        case ratingAvg = "rating_avg"
        case ratingCount = "rating_count"
        case savedAt = "saved_at"
    }
}
