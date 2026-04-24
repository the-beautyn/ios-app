import Foundation

// MARK: - NotificationSettings
//
// Client-shaped notification preferences returned by /user/settings.
// Owner-specific `in_app_enabled` is intentionally omitted — this is a
// client app.

struct NotificationSettings: Codable, Equatable {
    let pushEnabled: Bool
    let emailEnabled: Bool
    let smsEnabled: Bool
}

// MARK: - UserSettings

struct UserSettings: Codable, Equatable {
    let notifications: NotificationSettings
}
