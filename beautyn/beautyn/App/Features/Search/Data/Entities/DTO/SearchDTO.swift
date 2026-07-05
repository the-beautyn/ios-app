import Foundation

// MARK: - SearchRequestDTO
//
// Body of POST /search. The backend expects camelCase field names, so no
// CodingKeys are needed; `nil` optionals are omitted by the synthesized
// Encodable (the backend treats absent fields as unset).

struct SearchRequestDTO: Encodable {
    var query: String?
    var centerLat: Double?
    var centerLng: Double?
    var viewport: SearchViewportDTO?
    var locationType: String?
    var sortBy: String?
    var priceMin: Double?
    var priceMax: Double?
    var page: Int = 1
    var limit: Int = 20
}

struct SearchViewportDTO: Encodable {
    let neLat: Double
    let neLng: Double
    let swLat: Double
    let swLng: Double
}

// MARK: - FilterOptionsResponseDTO
//
// GET /search/filter-options — static, parameterless: the allowed sort keys
// and the global price range (min…max).

struct FilterOptionsResponseDTO: Decodable {
    let sortOptions: [String]
    let minPrice: Double?
    let maxPrice: Double?

    enum CodingKeys: String, CodingKey {
        case sortOptions = "sort_options"
        case minPrice = "min_price"
        case maxPrice = "max_price"
    }
}

// MARK: - SearchResponseDTO

struct SearchResponseDTO: Decodable {
    let items: [SearchSalonItemDTO]
    let page: Int
    let limit: Int
    let total: Int
    let meta: SearchMetaDTO?
}

struct SearchSalonItemDTO: Decodable {
    let salonId: String
    let name: String
    let address: String
    let rating: Double?
    let distanceKm: Double?
    let logoUrl: String?
    let latitude: Double?
    let longitude: Double?
    let imageUrl: String?
    let isSaved: Bool?

    enum CodingKeys: String, CodingKey {
        case name, address, rating, latitude, longitude
        case salonId = "salon_id"
        case distanceKm = "distance_km"
        case logoUrl = "logo_url"
        case imageUrl = "image_url"
        case isSaved = "is_saved"
    }
}

// MARK: - SearchPinsResponseDTO

struct SearchPinsResponseDTO: Decodable {
    let items: [SearchPinItemDTO]
}

struct SearchPinItemDTO: Decodable {
    let salonId: String
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case salonId = "salon_id"
        case latitude, longitude
    }
}

struct SearchMetaDTO: Decodable {
    let effectiveRadiusKm: Double?
    let geoSource: String?

    enum CodingKeys: String, CodingKey {
        case effectiveRadiusKm = "effective_radius_km"
        case geoSource = "geo_source"
    }
}

// MARK: - SearchHistoryItemDTO
//
// Item of GET /search/history — `id` is the history row id (used for
// per-item deletion), `salon_id` the salon it points to.

struct SearchHistoryItemDTO: Decodable {
    let id: String
    let salonId: String
    let salonName: String
    let city: String
    let logoUrl: String?
    let latitude: Double?
    let longitude: Double?
    let lastSearchedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, city, latitude, longitude
        case salonId = "salon_id"
        case salonName = "salon_name"
        case logoUrl = "logo_url"
        case lastSearchedAt = "last_searched_at"
    }
}

