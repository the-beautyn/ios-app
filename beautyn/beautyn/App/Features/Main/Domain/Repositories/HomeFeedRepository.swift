import Foundation

// MARK: - HomeFeedRepository

protocol HomeFeedRepository {
    func getHomeFeed(latitude: Double?, longitude: Double?) async throws -> HomeFeed
}
