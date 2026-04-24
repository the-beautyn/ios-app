import Foundation

// MARK: - OAuthSignInUseCase

protocol OAuthSignInUseCase {
    func execute(provider: String, idToken: String, nonce: String?, name: String?, secondName: String?) async throws -> OAuthSession
}

// MARK: - OAuthSignInUseCaseImpl

final class OAuthSignInUseCaseImpl: OAuthSignInUseCase {

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

    func execute(provider: String, idToken: String, nonce: String?, name: String?, secondName: String?) async throws -> OAuthSession {
        let result = try await repository.oauth(provider: provider, idToken: idToken, nonce: nonce, name: name, secondName: secondName)
        sessionManager.saveSession(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
            phoneVerificationRequired: result.phoneVerificationRequired
        )
        _ = try? await refreshCurrentUserUseCase.execute()
        return result
    }
}
