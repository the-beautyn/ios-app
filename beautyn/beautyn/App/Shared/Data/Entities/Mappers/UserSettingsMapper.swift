import Foundation

// MARK: - UserSettingsMapper

enum UserSettingsMapper {

    static func map(_ dto: UserSettingsDTO) -> UserSettings {
        UserSettings(notifications: map(dto.notifications))
    }

    static func map(_ dto: NotificationSettingsDTO) -> NotificationSettings {
        NotificationSettings(
            pushEnabled: dto.pushEnabled,
            emailEnabled: dto.emailEnabled,
            smsEnabled: dto.smsEnabled
        )
    }
}
