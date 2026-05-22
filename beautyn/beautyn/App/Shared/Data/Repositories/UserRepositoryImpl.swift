import Foundation

// MARK: - UserRepositoryImpl
//
// Composes `UserRemoteDataSource` and `UserLocalDataSource`. `refresh` is the
// only path that writes to the cache — keeps the cache always reflecting the
// latest server response.

final class UserRepositoryImpl: UserRepository {

    private let remote: UserRemoteDataSource
    private let local: UserLocalDataSource

    init(remote: UserRemoteDataSource, local: UserLocalDataSource) {
        self.remote = remote
        self.local = local
    }

    func getCached() -> UserProfile? {
        local.get()
    }

    func refresh() async throws -> UserProfile {
        let dto = try await remote.fetchMe()
        let profile = UserProfileMapper.map(dto)
        local.save(profile)
        return profile
    }

    func update(_ patch: UserProfilePatch) async throws -> UserProfile {
        let dto = try await remote.update(UserProfilePatchMapper.map(patch))
        let profile = UserProfileMapper.map(dto)
        local.save(profile)
        return profile
    }

    func clearCache() {
        local.clear()
    }
}
