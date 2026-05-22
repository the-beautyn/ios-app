import Foundation

// MARK: - LoginUseCase

protocol LoginUseCase {
    func execute(email: String, password: String) async throws -> AuthSession
}

// MARK: - LoginUseCaseImpl

final class LoginUseCaseImpl: LoginUseCase {

    private let repository: AuthRepository
    private let sessionManager: SessionManager
    private let refreshCurrentUserUseCase: RefreshCurrentUserUseCase

    init(
        repository: AuthRepository,
        sessionManager: SessionManager,
        refreshCurrentUserUseCase: RefreshCurrentUserUseCase
    ) {
        self.repository = repository
        self.sessionManager = sessionManager
        self.refreshCurrentUserUseCase = refreshCurrentUserUseCase
    }

    func execute(email: String, password: String) async throws -> AuthSession {
        let result = try await repository.login(email: email, password: password)
        sessionManager.saveSession(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
            phoneVerificationRequired: result.phoneVerificationRequired
        )
        _ = try? await refreshCurrentUserUseCase.execute()
        return result
    }
}
