import Foundation

// MARK: - RefreshTokenUseCase

protocol RefreshTokenUseCase {
    func execute() async throws
}

// MARK: - RefreshTokenError

enum RefreshTokenError: Error {
    case missingRefreshToken
}

// MARK: - RefreshTokenUseCaseImpl

@MainActor
final class RefreshTokenUseCaseImpl: RefreshTokenUseCase {

    private let repository: AuthRepository
    private let sessionManager: SessionManager

    init(repository: AuthRepository, sessionManager: SessionManager) {
        self.repository = repository
        self.sessionManager = sessionManager
    }

    func execute() async throws {
        guard let refreshToken = sessionManager.currentRefreshToken else {
            sessionManager.clearSession()
            throw RefreshTokenError.missingRefreshToken
        }

        do {
            let session = try await repository.refresh(refreshToken: refreshToken)
            sessionManager.updateTokens(
                accessToken: session.accessToken,
                refreshToken: session.refreshToken
            )
        } catch {
            sessionManager.clearSession()
            throw error
        }
    }
}
