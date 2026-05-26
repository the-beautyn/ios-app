import Foundation

// MARK: - GetSalonShareUseCase

protocol GetSalonShareUseCase {
    func execute(id: String) async throws -> SalonShare
}

// MARK: - GetSalonShareUseCaseImpl

final class GetSalonShareUseCaseImpl: GetSalonShareUseCase {

    private let repository: SalonRepository

    init(repository: SalonRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws -> SalonShare {
        try await repository.getShare(id: id)
    }
}
