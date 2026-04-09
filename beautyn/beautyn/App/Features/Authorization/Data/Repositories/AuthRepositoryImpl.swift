import Foundation

// MARK: - AuthRepositoryImpl

final class AuthRepositoryImpl: AuthRepository {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func checkEmail(_ email: String) async throws -> EmailStatus {
        let target = Target(type: AuthTarget.checkEmail(email: email))
        let response: CheckEmailResponseDTO = try await networkService.request(target)
        return AuthMapper.mapEmailStatus(response)
    }

    func login(email: String, password: String) async throws -> AuthSession {
        let target = Target(type: AuthTarget.login(email: email, password: password))
        let response: LoginResponseDTO = try await networkService.request(target)
        return AuthMapper.mapAuthSession(response)
    }

    func register(email: String, password: String, name: String, secondName: String) async throws -> AuthSession {
        let target = Target(type: AuthTarget.register(email: email, password: password, name: name, secondName: secondName, role: "client"))
        let response: RegisterResponseDTO = try await networkService.request(target)
        return AuthMapper.mapAuthSession(response)
    }

    func oauth(provider: String, idToken: String, nonce: String?, name: String?, secondName: String?) async throws -> OAuthSession {
        let target = Target(type: AuthTarget.oauth(provider: provider, idToken: idToken, nonce: nonce, name: name, secondName: secondName))
        let response: OAuthResponseDTO = try await networkService.request(target)
        return AuthMapper.mapOAuthSession(response)
    }

    func forgotPassword(email: String) async throws {
        let target = Target(type: AuthTarget.forgotPassword(email: email))
        try await networkService.request(target)
    }

    func sendPhoneOTP(phone: String) async throws {
        let target = Target(type: AuthTarget.sendPhoneOTP(phone: phone))
        try await networkService.request(target)
    }

    func verifyPhoneOTP(phone: String, code: String) async throws -> Bool {
        let target = Target(type: AuthTarget.verifyPhoneOTP(phone: phone, code: code))
        let response: VerifyOtpResponseDTO = try await networkService.request(target)
        return response.verified
    }

    func resendPhoneOTP(phone: String) async throws {
        let target = Target(type: AuthTarget.resendPhoneOTP(phone: phone))
        try await networkService.request(target)
    }

    func logout() async throws {
        let target = Target(type: AuthTarget.logout)
        try await networkService.request(target)
    }
}
