import Foundation

// MARK: - GetAppCategoriesUseCase

protocol GetAppCategoriesUseCase {
    func execute() async throws -> [AppCategory]
}

// MARK: - GetAppCategoriesUseCaseImpl

final class GetAppCategoriesUseCaseImpl: GetAppCategoriesUseCase {

    private let repository: SearchRepository

    init(repository: SearchRepository) {
        self.repository = repository
    }

    func execute() async throws -> [AppCategory] {
        try await repository.appCategories()
    }
}
