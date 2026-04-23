import Foundation

// MARK: - ResetPasswordUseCase

protocol ResetPasswordUseCase {
    func execute(token: String, newPassword: String) async throws
}

// MARK: - ResetPasswordUseCaseImpl

@MainActor
final class ResetPasswordUseCaseImpl: ResetPasswordUseCase {

    private let repository: AuthRepository
    private let sessionManager: SessionManager
    private let getMeUseCase: GetMeUseCase

    init(repository: AuthRepository, sessionManager: SessionManager, getMeUseCase: GetMeUseCase) {
        self.repository = repository
        self.sessionManager = sessionManager
        self.getMeUseCase = getMeUseCase
    }

    func execute(token: String, newPassword: String) async throws {
        let session = try await repository.resetPassword(token: token, newPassword: newPassword)

        sessionManager.saveSession(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            phoneVerificationRequired: false
        )
        _ = try? await getMeUseCase.execute()
    }
}
