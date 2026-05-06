import Foundation

// MARK: - ChangePasswordUseCase

protocol ChangePasswordUseCase {
    func execute(currentPassword: String, newPassword: String) async throws
}

// MARK: - ChangePasswordUseCaseImpl

@MainActor
final class ChangePasswordUseCaseImpl: ChangePasswordUseCase {

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

    func execute(currentPassword: String, newPassword: String) async throws {
        let session = try await repository.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword
        )

        sessionManager.saveSession(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            phoneVerificationRequired: false
        )
        _ = try? await refreshCurrentUserUseCase.execute()
    }
}
