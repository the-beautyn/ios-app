import Foundation

// MARK: - GetCurrentUserUseCase
//
// Cache-first lookup of the current user. Returns the cached profile when
// present; falls back to a remote refresh only if the cache is empty.

protocol GetCurrentUserUseCase {
    func execute() async throws -> UserProfile
}

// MARK: - GetCurrentUserUseCaseImpl

final class GetCurrentUserUseCaseImpl: GetCurrentUserUseCase {

    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func execute() async throws -> UserProfile {
        if let cached = repository.getCached() {
            return cached
        }
        return try await repository.refresh()
    }
}
