import Foundation

// MARK: - UserProfile

struct UserProfile: Codable {
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
}
