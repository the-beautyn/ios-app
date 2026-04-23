import Foundation

// MARK: - UserProfileDTO

struct UserProfileDTO: Decodable {
    let id: String
    let email: String
    let role: String
    let name: String?
    let secondName: String?
    let phone: String?
    let avatarUrl: String?
    let authProvider: String
    let isPhoneVerified: Bool
    let isProfileCreated: Bool
    let isOnboardingCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case id, email, role, name, phone
        case secondName = "second_name"
        case avatarUrl = "avatar_url"
        case authProvider = "auth_provider"
        case isPhoneVerified = "is_phone_verified"
        case isProfileCreated = "is_profile_created"
        case isOnboardingCompleted = "is_onboarding_completed"
    }
}
