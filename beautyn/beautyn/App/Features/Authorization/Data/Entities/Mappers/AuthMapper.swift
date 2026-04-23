import Foundation

enum AuthMapper {

    static func mapEmailStatus(_ dto: CheckEmailResponseDTO) -> EmailStatus {
        switch dto.status {
        case "not_found": return .notFound
        case "password": return .password
        case "apple": return .apple
        case "google": return .google
        default: return .notFound
        }
    }

    static func mapAuthSession(_ dto: LoginResponseDTO) -> AuthSession {
        AuthSession(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            expiresIn: dto.expiresIn,
            phoneVerificationRequired: dto.phoneVerificationRequired ?? false
        )
    }

    static func mapAuthSession(_ dto: RegisterResponseDTO) -> AuthSession {
        AuthSession(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            expiresIn: dto.expiresIn,
            phoneVerificationRequired: dto.phoneVerificationRequired ?? false
        )
    }

    static func mapRefreshSession(_ dto: RefreshResponseDTO) -> AuthSession {
        AuthSession(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            expiresIn: dto.expiresIn,
            phoneVerificationRequired: false
        )
    }

    static func mapResetSession(_ dto: ResetPasswordResponseDTO) -> AuthSession {
        AuthSession(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            expiresIn: dto.expiresIn,
            phoneVerificationRequired: false
        )
    }

    static func mapOAuthSession(_ dto: OAuthResponseDTO) -> OAuthSession {
        OAuthSession(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            expiresIn: dto.expiresIn,
            phoneVerificationRequired: dto.phoneVerificationRequired ?? false,
            isNewUser: dto.isNewUser ?? false
        )
    }
}
