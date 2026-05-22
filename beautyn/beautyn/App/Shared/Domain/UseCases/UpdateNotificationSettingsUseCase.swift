import Foundation

// MARK: - UpdateNotificationSettingsUseCase

protocol UpdateNotificationSettingsUseCase {
    @discardableResult
    func execute(
        pushEnabled: Bool?,
        emailEnabled: Bool?,
        smsEnabled: Bool?
    ) async throws -> UserSettings
}

// MARK: - UpdateNotificationSettingsUseCaseImpl

final class UpdateNotificationSettingsUseCaseImpl: UpdateNotificationSettingsUseCase {

    private let repository: UserSettingsRepository

    init(repository: UserSettingsRepository) {
        self.repository = repository
    }

    func execute(
        pushEnabled: Bool?,
        emailEnabled: Bool?,
        smsEnabled: Bool?
    ) async throws -> UserSettings {
        try await repository.updateNotifications(
            pushEnabled: pushEnabled,
            emailEnabled: emailEnabled,
            smsEnabled: smsEnabled
        )
    }
}
