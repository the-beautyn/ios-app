import Foundation

// MARK: - GetSalonByIdUseCase

protocol GetSalonByIdUseCase {
    func execute(id: String) async throws -> Salon
}

// MARK: - GetSalonByIdUseCaseImpl

final class GetSalonByIdUseCaseImpl: GetSalonByIdUseCase {

    private let repository: SalonRepository

    init(repository: SalonRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws -> Salon {
        try await repository.getSalon(id: id)
    }
}
