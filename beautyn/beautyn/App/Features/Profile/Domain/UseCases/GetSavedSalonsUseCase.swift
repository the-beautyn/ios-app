import Foundation

// MARK: - GetSavedSalonsUseCase

protocol GetSavedSalonsUseCase {
    func execute(query: String?, page: Int?, limit: Int?) async throws -> SavedSalonsList
}

// MARK: - GetSavedSalonsUseCaseImpl

final class GetSavedSalonsUseCaseImpl: GetSavedSalonsUseCase {

    private let repository: SavedSalonsRepository

    init(repository: SavedSalonsRepository) {
        self.repository = repository
    }

    func execute(query: String?, page: Int?, limit: Int?) async throws -> SavedSalonsList {
        try await repository.list(query: query, page: page, limit: limit)
    }
}
