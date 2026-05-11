import Foundation

// MARK: - DeleteAccountUseCase

protocol DeleteAccountUseCase {
    func execute() async throws
}

// MARK: - DeleteAccountUseCaseImpl

@MainActor
final class DeleteAccountUseCaseImpl: DeleteAccountUseCase {

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

    func execute() async throws {
        // Backend-first. If the server call fails, the local session
        // stays intact so the user can retry. Clearing it on failure
        // would lie to the user about an irreversible action.
        try await repository.deleteAccount()
        sessionManager.clearSession()
        clearUserUseCase.execute()
    }
}
