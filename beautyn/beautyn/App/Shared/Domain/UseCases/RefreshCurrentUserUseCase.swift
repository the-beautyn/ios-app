import Foundation

// MARK: - RefreshCurrentUserUseCase
//
// Forces a network fetch of the current user, overwriting the cache. Used by
// auth flows and by pull-to-refresh gestures.

protocol RefreshCurrentUserUseCase {
    @discardableResult
    func execute() async throws -> UserProfile
}

// MARK: - RefreshCurrentUserUseCaseImpl

final class RefreshCurrentUserUseCaseImpl: RefreshCurrentUserUseCase {

    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func execute() async throws -> UserProfile {
        try await repository.refresh()
    }
}
