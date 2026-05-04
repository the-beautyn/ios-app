import Foundation

// MARK: - SavedSalonsRepositoryImpl

final class SavedSalonsRepositoryImpl: SavedSalonsRepository {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func list(query: String?, page: Int?, limit: Int?) async throws -> SavedSalonsList {
        let target = Target(type: SavedSalonsTarget.list(q: query, page: page, limit: limit))
        let response: SavedSalonListResponseDTO = try await networkService.request(target)
        return SavedSalonsMapper.map(response)
    }

    func save(salonId: String) async throws {
        let target = Target(type: SavedSalonsTarget.save(salonId: salonId))
        try await networkService.request(target)
    }

    func unsave(salonId: String) async throws {
        let target = Target(type: SavedSalonsTarget.unsave(salonId: salonId))
        try await networkService.request(target)
    }
}
