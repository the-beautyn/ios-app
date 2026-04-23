import Foundation

// MARK: - ForgotPasswordUseCase

protocol ForgotPasswordUseCase {
    func execute(email: String) async throws
}

// MARK: - ForgotPasswordUseCaseImpl

final class ForgotPasswordUseCaseImpl: ForgotPasswordUseCase {

    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(email: String) async throws {
        try await repository.forgotPassword(email: email)
    }
}
