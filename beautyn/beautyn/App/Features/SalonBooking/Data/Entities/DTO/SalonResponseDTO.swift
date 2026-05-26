import Foundation

// MARK: - SalonResponseDTO

struct SalonResponseDTO: Decodable {
    let id: String
    let name: String
    let addressLine: String?
    let city: String?
    let country: String?
    let latitude: Double?
    let longitude: Double?
    let phone: String?
    let email: String?
    let provider: String?
    let description: String?
    let ratingAvg: Double?
    let ratingCount: Int?
    let workingSchedule: String?
    let imagesCount: Int?
    let coverImageUrl: String?
    let isSaved: Bool?
    let services: [SalonServiceDTO]?
    let workers: [SalonWorkerDTO]?
    let categories: [SalonCategoryDTO]?
    let images: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case addressLine = "address_line"
        case city
        case country
        case latitude
        case longitude
        case phone
        case email
        case provider
        case description
        case ratingAvg = "rating_avg"
        case ratingCount = "rating_count"
        case workingSchedule = "working_schedule"
        case imagesCount = "images_count"
        case coverImageUrl = "cover_image_url"
        case isSaved = "is_saved"
        case services
        case workers
        case categories
        case images
    }
}

// MARK: - SalonServiceDTO

struct SalonServiceDTO: Decodable {
    let id: String
    let salonId: String
    let categoryId: String?
    let name: String
    let description: String?
    let duration: Int
    let price: Double
    let currency: String
    let isActive: Bool
    let sortOrder: Int?
    let workerIds: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case salonId = "salon_id"
        case categoryId = "category_id"
        case name
        case description
        case duration
        case price
        case currency
        case isActive = "is_active"
        case sortOrder = "sort_order"
        case workerIds = "worker_ids"
    }
}

// MARK: - SalonWorkerDTO

struct SalonWorkerDTO: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let position: String?
    let description: String?
    let photoUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case position
        case description
        case photoUrl = "photo_url"
    }
}

// MARK: - SalonCategoryDTO

struct SalonCategoryDTO: Decodable {
    let id: String
    let salonId: String
    let name: String
    let color: String?
    let sortOrder: Int?
    let serviceIds: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case salonId = "salon_id"
        case name
        case color
        case sortOrder = "sort_order"
        case serviceIds = "service_ids"
    }
}

// MARK: - SalonShareResponseDTO

struct SalonShareResponseDTO: Decodable {
    let url: String
    let title: String
    let description: String?
}
