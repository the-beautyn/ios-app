import Foundation

// MARK: - HomeFeedRepositoryImpl

final class HomeFeedRepositoryImpl: HomeFeedRepository {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getHomeFeed(latitude: Double?, longitude: Double?) async throws -> HomeFeed {
        let target = Target(type: HomeFeedTarget.getHomeFeed(lat: latitude, lon: longitude))
        let response: HomeFeedResponseDTO = try await networkService.request(target)
        return HomeFeedMapper.map(response)
    }
}
