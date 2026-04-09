import Foundation

struct CheckEmailResponseDTO: Decodable {
    let status: String
}

struct LoginResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let phoneVerificationRequired: Bool?
}

struct RegisterResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let phoneVerificationRequired: Bool?
}

struct OAuthResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let phoneVerificationRequired: Bool?
    let isNewUser: Bool?
}

struct VerifyOtpResponseDTO: Decodable {
    let verified: Bool
}
