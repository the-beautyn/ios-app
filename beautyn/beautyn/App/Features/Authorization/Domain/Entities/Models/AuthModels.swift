import Foundation

enum EmailStatus {
    case notFound
    case password
    case apple
    case google
}

struct AuthSession {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let phoneVerificationRequired: Bool
}

struct OAuthSession {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let phoneVerificationRequired: Bool
    let isNewUser: Bool
}
