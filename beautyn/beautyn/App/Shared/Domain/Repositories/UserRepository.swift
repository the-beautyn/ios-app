import Foundation

// MARK: - UserRepository
//
// Domain-facing seam over the two user data sources (remote + local cache).
// ViewModels never touch this — they go through the user-related UseCases.

protocol UserRepository {
    /// Returns the last-known cached profile, or `nil` if nothing is cached.
    /// Never hits the network.
    func getCached() -> UserProfile?

    /// Forces a network fetch and writes through to the cache.
    @discardableResult
    func refresh() async throws -> UserProfile

    /// PATCHes the current user with `patch`, writes the server's response
    /// through to the cache, and returns the updated domain entity.
    @discardableResult
    func update(_ patch: UserProfilePatch) async throws -> UserProfile

    /// Clears the cached profile only. Does not touch session/tokens — those
    /// are owned by `SessionManager`.
    func clearCache()
}
