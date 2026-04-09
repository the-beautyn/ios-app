import Foundation

// MARK: - GetMeUseCase

protocol GetMeUseCase {
    @discardableResult
    func execute() async throws -> UserProfile
}

// MARK: - GetMeUseCaseImpl

final class GetMeUseCaseImpl: GetMeUseCase {

    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func execute() async throws -> UserProfile {
        try await userRepository.fetchMe()
    }
}
