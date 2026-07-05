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

    func filterOptions() async throws -> SearchFilterOptions {
        let target = Target(type: SearchTarget.filterOptions)
        let response: FilterOptionsResponseDTO = try await networkService.request(target)
        return SearchMapper.map(response)
    }

    func history(limit: Int) async throws -> [SearchHistoryItem] {
        let target = Target(type: SearchTarget.history(limit: limit))
        let response: [SearchHistoryItemDTO] = try await networkService.request(target)
        return response.map { SearchMapper.map($0) }
    }

    func clearHistory() async throws {
        try await networkService.request(Target(type: SearchTarget.clearHistory))
    }

    func deleteHistoryItem(id: String) async throws {
        try await networkService.request(Target(type: SearchTarget.deleteHistoryItem(id: id)))
    }

}
