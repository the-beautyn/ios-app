import Foundation

// MARK: - CheckEmailUseCase

protocol CheckEmailUseCase {
    func execute(email: String) async throws -> EmailStatus
}

// MARK: - CheckEmailUseCaseImpl

final class CheckEmailUseCaseImpl: CheckEmailUseCase {

    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(email: String) async throws -> EmailStatus {
        try await repository.checkEmail(email)
    }
}
