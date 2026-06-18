import Foundation

// MARK: - AltegioBookableServicesResponseDTO

struct AltegioBookableServicesResponseDTO: Decodable {
    let categories: [AltegioBookableServiceCategoryDTO]
    let services: [AltegioBookableServiceDTO]
}

// MARK: - AltegioBookableServiceCategoryDTO

struct AltegioBookableServiceCategoryDTO: Decodable {
    let id: String
    let name: String
}

// MARK: - AltegioBookableServiceDTO

struct AltegioBookableServiceDTO: Decodable {
    let id: String
    let categoryId: String?
    let name: String
    let price: Double
    let durationSec: Int?
    let isAvailable: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case name
        case price
        case durationSec = "duration_sec"
        case isAvailable = "is_available"
    }
}
