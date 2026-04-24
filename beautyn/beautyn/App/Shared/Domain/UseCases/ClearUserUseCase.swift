import Foundation

// MARK: - ClearUserUseCase
//
// Clears the cached user profile. Does NOT clear the session — tokens and
// auth state are owned by `SessionManager`. Whoever performs logout should
// call both (SessionManager.clearSession + ClearUserUseCase.execute).

protocol ClearUserUseCase {
    func execute()
}

// MARK: - ClearUserUseCaseImpl

final class ClearUserUseCaseImpl: ClearUserUseCase {

    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func execute() {
        repository.clearCache()
    }
}
