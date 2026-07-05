import Foundation

// MARK: - ClearSearchHistoryUseCase

protocol ClearSearchHistoryUseCase {
    func execute() async throws
}

// MARK: - ClearSearchHistoryUseCaseImpl

final class ClearSearchHistoryUseCaseImpl: ClearSearchHistoryUseCase {

    private let repository: SearchRepository

    init(repository: SearchRepository) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.clearHistory()
    }
}
