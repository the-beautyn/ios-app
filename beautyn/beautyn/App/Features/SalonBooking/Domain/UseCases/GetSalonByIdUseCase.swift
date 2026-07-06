import Foundation

// MARK: - GetSalonByIdUseCase

protocol GetSalonByIdUseCase {
    /// `isFromSearch` marks the fetch as coming from the search flow — the
    /// backend records a search-history visit for the authenticated user.
    func execute(id: String, isFromSearch: Bool) async throws -> Salon
}

extension GetSalonByIdUseCase {
    func execute(id: String) async throws -> Salon {
        try await execute(id: id, isFromSearch: false)
    }
}

// MARK: - GetSalonByIdUseCaseImpl

final class GetSalonByIdUseCaseImpl: GetSalonByIdUseCase {

    private let repository: SalonRepository

    init(repository: SalonRepository) {
        self.repository = repository
    }

    func execute(id: String, isFromSearch: Bool) async throws -> Salon {
        try await repository.getSalon(id: id, isFromSearch: isFromSearch)
    }
}
