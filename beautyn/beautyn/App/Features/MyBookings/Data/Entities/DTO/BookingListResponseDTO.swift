import Foundation

// MARK: - BookingListResponseDTO

struct BookingListResponseDTO: Decodable {
    let items: [BookingItemDTO]
    let nextCursor: String?
    let limit: Int?

    enum CodingKeys: String, CodingKey {
        case items
        case nextCursor = "next_cursor"
        case limit
    }
}

// MARK: - BookingItemDTO

struct BookingItemDTO: Decodable {
    let id: String
    let salonId: String
    let salon: BookingSalonDTO?
    let status: String
    let datetime: String
    let endDatetime: String?
    let cancelledAt: String?
    let serviceNames: [String]?
    let totalPrice: Double?
    let currency: String?
    let durationMinutes: Int?
    /// Short public link to manage the booking. Optional — the list endpoint
    /// may omit it; populated by the create-booking response for now.
    let shortLink: String?
    /// Provider payload — the only place the list endpoint carries per-service
    /// price / description (the flat `service_names` is names only).
    let providerSpecific: BookingProviderSpecificDTO?

    enum CodingKeys: String, CodingKey {
        case id
        case salonId = "salon_id"
        case salon
        case status
        case datetime
        case endDatetime = "end_datetime"
        case cancelledAt = "cancelled_at"
        case serviceNames = "service_names"
        case totalPrice = "total_price"
        case currency
        case durationMinutes = "duration_minutes"
        case shortLink = "short_link"
        case providerSpecific = "provider_specific"
    }
}

// MARK: - BookingProviderSpecificDTO
//
// Per-service breakdown lives under one of the provider blocks. EasyWeek carries
// name + description + price; Altegio carries title + cost. Prices are in the
// same minor unit (cents) as the top-level `total_price`.

struct BookingProviderSpecificDTO: Decodable {
    let easyweek: BookingEasyweekDTO?
    let altegio: BookingAltegioDTO?
}

struct BookingEasyweekDTO: Decodable {
    let orderedServices: [BookingEasyweekServiceDTO]?

    enum CodingKeys: String, CodingKey {
        case orderedServices = "ordered_services"
    }
}

struct BookingEasyweekServiceDTO: Decodable {
    let externalUuid: String?
    let name: String?
    let description: String?
    let price: Double?

    enum CodingKeys: String, CodingKey {
        case externalUuid = "external_uuid"
        case name
        case description
        case price
    }
}

struct BookingAltegioDTO: Decodable {
    let services: [BookingAltegioServiceDTO]?
}

struct BookingAltegioServiceDTO: Decodable {
    let externalId: String?
    let title: String?
    let cost: Double?
    let costToPay: Double?

    enum CodingKeys: String, CodingKey {
        case externalId = "external_id"
        case title
        case cost
        case costToPay = "cost_to_pay"
    }
}

// MARK: - BookingSalonDTO

struct BookingSalonDTO: Decodable {
    let id: String
    let name: String?
    let addressLine: String?
    let latitude: Double?
    let longitude: Double?
    let coverImageUrl: String?
    let timezone: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
        case addressLine = "address_line"
        case coverImageUrl = "cover_image_url"
        case timezone
    }
}
