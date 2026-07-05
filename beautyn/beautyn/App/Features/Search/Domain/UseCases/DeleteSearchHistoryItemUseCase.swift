import Foundation

// MARK: - DeleteSearchHistoryItemUseCase

protocol DeleteSearchHistoryItemUseCase {
    /// Deletes one history entry by its history row id.
    func execute(id: String) async throws
}

// MARK: - DeleteSearchHistoryItemUseCaseImpl

final class DeleteSearchHistoryItemUseCaseImpl: DeleteSearchHistoryItemUseCase {

    private let repository: SearchRepository

    init(repository: SearchRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws {
        try await repository.deleteHistoryItem(id: id)
    }
}
