import Foundation

// MARK: - NotificationSettingsDTO

struct NotificationSettingsDTO: Decodable {
    let pushEnabled: Bool
    let emailEnabled: Bool
    let smsEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case pushEnabled = "push_enabled"
        case emailEnabled = "email_enabled"
        case smsEnabled = "sms_enabled"
    }
}

// MARK: - UserSettingsDTO

struct UserSettingsDTO: Decodable {
    let notifications: NotificationSettingsDTO
}
