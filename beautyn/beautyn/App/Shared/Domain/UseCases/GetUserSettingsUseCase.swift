import Foundation

// MARK: - GetUserSettingsUseCase

protocol GetUserSettingsUseCase {
    @discardableResult
    func execute() async throws -> UserSettings
}

// MARK: - GetUserSettingsUseCaseImpl

final class GetUserSettingsUseCaseImpl: GetUserSettingsUseCase {

    private let repository: UserSettingsRepository

    init(repository: UserSettingsRepository) {
        self.repository = repository
    }

    func execute() async throws -> UserSettings {
        try await repository.fetchSettings()
    }
}
