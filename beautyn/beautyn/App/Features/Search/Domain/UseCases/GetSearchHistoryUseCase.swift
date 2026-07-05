import Foundation

// MARK: - GetSearchHistoryUseCase

protocol GetSearchHistoryUseCase {
    func execute(limit: Int) async throws -> [SearchHistoryItem]
}

// MARK: - GetSearchHistoryUseCaseImpl

final class GetSearchHistoryUseCaseImpl: GetSearchHistoryUseCase {

    private let repository: SearchRepository

    init(repository: SearchRepository) {
        self.repository = repository
    }

    func execute(limit: Int) async throws -> [SearchHistoryItem] {
        try await repository.history(limit: limit)
    }
}
