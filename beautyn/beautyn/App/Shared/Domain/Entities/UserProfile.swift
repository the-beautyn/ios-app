import Foundation

// MARK: - Sex

enum Sex: String, Codable {
    case male
    case female
    case preferNotToSay = "prefer_not_to_say"
    case other
}

// MARK: - UserProfile

struct UserProfile: Codable {
    let id: String
    let email: String
    let role: String
    let name: String?
    let secondName: String?
    let phone: String?
    let avatarUrl: String?
    let birthDate: Date?
    let city: String?
    let sex: Sex?
    let authProvider: String
    let isPhoneVerified: Bool
    let isProfileCreated: Bool
    let isOnboardingCompleted: Bool
}
