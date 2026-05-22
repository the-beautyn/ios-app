import Foundation

// MARK: - GetHomeFeedUseCase

protocol GetHomeFeedUseCase {
    func execute(latitude: Double?, longitude: Double?) async throws -> HomeFeed
}

// MARK: - GetHomeFeedUseCaseImpl

final class GetHomeFeedUseCaseImpl: GetHomeFeedUseCase {

    private let repository: HomeFeedRepository

    init(repository: HomeFeedRepository) {
        self.repository = repository
    }

    func execute(latitude: Double?, longitude: Double?) async throws -> HomeFeed {
        try await repository.getHomeFeed(latitude: latitude, longitude: longitude)
    }
}
