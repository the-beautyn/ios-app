import Foundation

// MARK: - SavedSalonsMapper

enum SavedSalonsMapper {

    static func map(_ dto: SavedSalonListResponseDTO) -> SavedSalonsList {
        SavedSalonsList(
            items: dto.items.map { HomeFeedMapper.mapSavedSalon($0) },
            page: dto.page,
            limit: dto.limit,
            total: dto.total
        )
    }
}
