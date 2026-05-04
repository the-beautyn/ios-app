import Foundation

// MARK: - SavedSalonListResponseDTO

// Reuses `SavedSalonItemDTO` defined in
// `Features/Home/Data/Entities/DTO/HomeFeedResponseDTO.swift`.
struct SavedSalonListResponseDTO: Decodable {
    let items: [SavedSalonItemDTO]
    let page: Int
    let limit: Int
    let total: Int
}
