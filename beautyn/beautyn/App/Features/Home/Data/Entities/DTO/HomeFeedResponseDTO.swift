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
    let salonTimezone: String?
    let datetime: String
    let endDatetime: String?
    let totalPriceCents: Int?
    let durationMinutes: Int?
    let serviceNames: [String]?
    let services: [HomeFeedNextBookingServiceDTO]?
    let shortLink: String?

    enum CodingKeys: String, CodingKey {
        case bookingId = "booking_id"
        case salonId = "salon_id"
        case salonName = "salon_name"
        case salonCoverImageUrl = "salon_cover_image_url"
        case salonAddressLine = "salon_address_line"
        case salonTimezone = "salon_timezone"
        case datetime
        case endDatetime = "end_datetime"
        case totalPriceCents = "total_price_cents"
        case durationMinutes = "duration_minutes"
        case serviceNames = "service_names"
        case services
        case shortLink = "short_link"
    }
}

// MARK: - HomeFeedNextBookingServiceDTO

struct HomeFeedNextBookingServiceDTO: Decodable {
    let id: String
    let name: String
    let description: String?
    let priceCents: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case priceCents = "price_cents"
    }
}

// MARK: - HomeFeedSectionDTO

struct HomeFeedSectionDTO: Decodable {
    let id: String
    let type: String
    let title: String
    let emoji: String?
    let items: [HomeFeedSalonCardDTO]
    let searchParams: HomeFeedSectionSearchParamsDTO?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case title
        case emoji
        case items
        case searchParams = "search_params"
    }
}

// MARK: - HomeFeedSectionSearchParamsDTO

/// The POST /search parameters that reproduce a section, so a section tap
/// can replay it on the Search tab.
struct HomeFeedSectionSearchParamsDTO: Decodable {
    let query: String?
    let appCategoryIds: [String]?
    let sortBy: String?
    let priceMin: Double?
    let priceMax: Double?
    let date: String?

    enum CodingKeys: String, CodingKey {
        case query
        case date
        case appCategoryIds = "app_category_ids"
        case sortBy = "sort_by"
        case priceMin = "price_min"
        case priceMax = "price_max"
    }
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
