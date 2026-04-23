import Foundation

struct CheckEmailResponseDTO: Decodable {
    let status: String
}

struct LoginResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let phoneVerificationRequired: Bool?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case phoneVerificationRequired = "phone_verification_required"
    }
}

struct RegisterResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let phoneVerificationRequired: Bool?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case phoneVerificationRequired = "phone_verification_required"
    }
}

struct OAuthResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let phoneVerificationRequired: Bool?
    let isNewUser: Bool?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case phoneVerificationRequired = "phone_verification_required"
        case isNewUser = "is_new_user"
    }
}

struct VerifyOtpResponseDTO: Decodable {
    let verified: Bool
}

struct RefreshResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

struct ResetPasswordResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}
