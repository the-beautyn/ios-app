import Foundation

// MARK: - LoginUseCase

protocol LoginUseCase {
    func execute(email: String, password: String) async throws -> AuthSession
}

// MARK: - LoginUseCaseImpl

final class LoginUseCaseImpl: LoginUseCase {

    private let repository: AuthRepository
    private let sessionManager: SessionManager
    private let getMeUseCase: GetMeUseCase

    init(repository: AuthRepository, sessionManager: SessionManager, getMeUseCase: GetMeUseCase) {
        self.repository = repository
        self.sessionManager = sessionManager
        self.getMeUseCase = getMeUseCase
    }

    func execute(email: String, password: String) async throws -> AuthSession {
        let result = try await repository.login(email: email, password: password)
        sessionManager.saveSession(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
            phoneVerificationRequired: result.phoneVerificationRequired
        )
        _ = try? await getMeUseCase.execute()
        return result
    }
}
