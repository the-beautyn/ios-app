import Foundation

// MARK: - UserRemoteDataSource
//
// Wraps the network call for `GET /user/me`. Returns a DTO — callers (the
// Repository) are responsible for mapping to a domain entity. No caching
// here.

final class UserRemoteDataSource {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func fetchMe() async throws -> UserProfileDTO {
        let target = Target(type: UserTarget.getMe)
        return try await networkService.request(target)
    }
}
