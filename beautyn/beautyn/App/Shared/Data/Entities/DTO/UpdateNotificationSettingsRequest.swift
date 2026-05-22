import Foundation

// MARK: - UpdateNotificationSettingsRequest
//
// Body for PATCH /user/settings/notifications. All fields optional — only
// changed values are sent. `inAppEnabled` is owner-only and ignored by this
// client app.

struct UpdateNotificationSettingsRequest: Encodable {
    let pushEnabled: Bool?
    let emailEnabled: Bool?
    let smsEnabled: Bool?

    init(
        pushEnabled: Bool? = nil,
        emailEnabled: Bool? = nil,
        smsEnabled: Bool? = nil
    ) {
        self.pushEnabled = pushEnabled
        self.emailEnabled = emailEnabled
        self.smsEnabled = smsEnabled
    }

    enum CodingKeys: String, CodingKey {
        case pushEnabled = "push_enabled"
        case emailEnabled = "email_enabled"
        case smsEnabled = "sms_enabled"
    }
}
