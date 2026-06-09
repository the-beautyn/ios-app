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
    let serviceNames: [String]?
    let totalPrice: Double?
    let currency: String?
    let durationMinutes: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case salonId = "salon_id"
        case salon
        case status
        case datetime
        case endDatetime = "end_datetime"
        case serviceNames = "service_names"
        case totalPrice = "total_price"
        case currency
        case durationMinutes = "duration_minutes"
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
