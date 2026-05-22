import Foundation

// MARK: - UpdateUserProfileUseCase
//
// Submits a partial update for the current user. Repository writes the server
// response through to the cache, so any other screen reading via
// `GetCurrentUserUseCase` will see the new values without a refetch.

protocol UpdateUserProfileUseCase {
    func execute(_ patch: UserProfilePatch) async throws -> UserProfile
}

// MARK: - UpdateUserProfileUseCaseImpl

final class UpdateUserProfileUseCaseImpl: UpdateUserProfileUseCase {

    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func execute(_ patch: UserProfilePatch) async throws -> UserProfile {
        try await repository.update(patch)
    }
}
