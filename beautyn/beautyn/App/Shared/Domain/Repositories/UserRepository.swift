import Foundation

// MARK: - UserRepository

protocol UserRepository {
    func fetchMe() async throws -> UserProfile
    func getCachedProfile() -> UserProfile?
    func clearProfile()
}
