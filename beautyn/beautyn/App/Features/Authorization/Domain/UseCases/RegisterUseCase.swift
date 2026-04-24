import Foundation

// MARK: - RegisterUseCase

protocol RegisterUseCase {
    func execute(email: String, password: String, name: String, secondName: String) async throws -> AuthSession
}

// MARK: - RegisterUseCaseImpl

final class RegisterUseCaseImpl: RegisterUseCase {

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

    func execute(email: String, password: String, name: String, secondName: String) async throws -> AuthSession {
        let result = try await repository.register(email: email, password: password, name: name, secondName: secondName)
        sessionManager.saveSession(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
            phoneVerificationRequired: result.phoneVerificationRequired
        )
        _ = try? await refreshCurrentUserUseCase.execute()
        return result
    }
}
