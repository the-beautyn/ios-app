import Foundation

// MARK: - UserSettingsRepository

protocol UserSettingsRepository {
    func fetchSettings() async throws -> UserSettings

    func updateNotifications(
        pushEnabled: Bool?,
        emailEnabled: Bool?,
        smsEnabled: Bool?
    ) async throws -> UserSettings
}
