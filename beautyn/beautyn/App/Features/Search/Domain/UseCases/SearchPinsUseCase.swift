import Foundation

// MARK: - SearchPinsUseCase

protocol SearchPinsUseCase {
    func execute(_ query: SearchQuery) async throws -> [SearchPin]
}

// MARK: - SearchPinsUseCaseImpl

final class SearchPinsUseCaseImpl: SearchPinsUseCase {

    private let repository: SearchRepository

    init(repository: SearchRepository) {
        self.repository = repository
    }

    func execute(_ query: SearchQuery) async throws -> [SearchPin] {
        try await repository.pins(query)
    }
}
