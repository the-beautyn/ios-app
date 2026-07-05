import Foundation

// MARK: - GetSearchFilterOptionsUseCase

protocol GetSearchFilterOptionsUseCase {
    /// Static bounds for the sort/price filter sheet (sort keys + the global
    /// price range) — fetched once per screen lifetime.
    func execute() async throws -> SearchFilterOptions
}

// MARK: - GetSearchFilterOptionsUseCaseImpl

final class GetSearchFilterOptionsUseCaseImpl: GetSearchFilterOptionsUseCase {

    private let repository: SearchRepository

    init(repository: SearchRepository) {
        self.repository = repository
    }

    func execute() async throws -> SearchFilterOptions {
        try await repository.filterOptions()
    }
}
