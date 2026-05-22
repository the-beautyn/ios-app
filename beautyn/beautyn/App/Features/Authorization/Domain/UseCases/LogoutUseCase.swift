import Foundation

// MARK: - LogoutUseCase

protocol LogoutUseCase {
    func execute() async
}

// MARK: - LogoutUseCaseImpl

@MainActor
final class LogoutUseCaseImpl: LogoutUseCase {

    private let repository: AuthRepository
    private let sessionManager: SessionManager
    private let clearUserUseCase: ClearUserUseCase

    init(
        repository: AuthRepository,
        sessionManager: SessionManager,
        clearUserUseCase: ClearUserUseCase
    ) {
        self.repository = repository
        self.sessionManager = sessionManager
        self.clearUserUseCase = clearUserUseCase
    }

    func execute() async {
        // Best-effort: backend revocation is opportunistic. Network errors,
        // 401, and 5xx all leave the local token dead — clear unconditionally.
        try? await repository.logout()
        sessionManager.clearSession()
        clearUserUseCase.execute()
    }
}
