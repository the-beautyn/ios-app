import Foundation

// MARK: - UserRepositoryImpl

final class UserRepositoryImpl: UserRepository {

    private let networkService: NetworkService
    private let defaultsService: StorageService

    init(networkService: NetworkService, defaultsService: StorageService) {
        self.networkService = networkService
        self.defaultsService = defaultsService
    }

    func fetchMe() async throws -> UserProfile {
        let target = Target(type: UserTarget.getMe)
        let dto: UserProfileDTO = try await networkService.request(target)
        let profile = UserProfileMapper.map(dto)
        defaultsService.storeValue(profile, for: DefaultsKeys.userProfile)
        return profile
    }

    func getCachedProfile() -> UserProfile? {
        defaultsService.retrieveValue(for: DefaultsKeys.userProfile)
    }

    func clearProfile() {
        defaultsService.removeValue(for: DefaultsKeys.userProfile)
    }
}
