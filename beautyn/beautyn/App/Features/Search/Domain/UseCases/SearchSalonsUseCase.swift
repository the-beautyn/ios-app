import Foundation

// MARK: - SearchSalonsUseCase

protocol SearchSalonsUseCase {
    func execute(_ query: SearchQuery) async throws -> SearchResults
}

// MARK: - SearchSalonsUseCaseImpl

final class SearchSalonsUseCaseImpl: SearchSalonsUseCase {

    private let repository: SearchRepository

    init(repository: SearchRepository) {
        self.repository = repository
    }

    func execute(_ query: SearchQuery) async throws -> SearchResults {
        try await repository.search(query)
    }
}
