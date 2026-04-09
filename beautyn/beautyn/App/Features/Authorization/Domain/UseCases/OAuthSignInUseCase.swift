import Foundation

// MARK: - OAuthSignInUseCase

protocol OAuthSignInUseCase {
    func execute(provider: String, idToken: String, nonce: String?, name: String?, secondName: String?) async throws -> OAuthSession
}

// MARK: - OAuthSignInUseCaseImpl

final class OAuthSignInUseCaseImpl: OAuthSignInUseCase {

    private let repository: AuthRepository
    private let sessionManager: SessionManager
    private let getMeUseCase: GetMeUseCase

    init(repository: AuthRepository, sessionManager: SessionManager, getMeUseCase: GetMeUseCase) {
        self.repository = repository
        self.sessionManager = sessionManager
        self.getMeUseCase = getMeUseCase
    }

    func execute(provider: String, idToken: String, nonce: String?, name: String?, secondName: String?) async throws -> OAuthSession {
        let result = try await repository.oauth(provider: provider, idToken: idToken, nonce: nonce, name: name, secondName: secondName)
        sessionManager.saveSession(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
            phoneVerificationRequired: result.phoneVerificationRequired
        )
        _ = try? await getMeUseCase.execute()
        return result
    }
}
