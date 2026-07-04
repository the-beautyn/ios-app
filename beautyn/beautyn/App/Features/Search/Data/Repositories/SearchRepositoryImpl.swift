import Foundation

// MARK: - SearchRepositoryImpl

final class SearchRepositoryImpl: SearchRepository {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func search(_ query: SearchQuery) async throws -> SearchResults {
        let target = Target(type: SearchTarget.search(SearchMapper.makeRequestDTO(query)))
        let response: SearchResponseDTO = try await networkService.request(target)
        return SearchMapper.map(response)
    }

    func pins(_ query: SearchQuery) async throws -> [SearchPin] {
        let target = Target(type: SearchTarget.pins(SearchMapper.makeRequestDTO(query)))
        let response: SearchPinsResponseDTO = try await networkService.request(target)
        return SearchMapper.map(response)
    }
}
