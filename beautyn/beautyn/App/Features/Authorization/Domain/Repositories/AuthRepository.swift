import Foundation

protocol AuthRepository {
    func checkEmail(_ email: String) async throws -> EmailStatus
    func login(email: String, password: String) async throws -> AuthSession
    func register(email: String, password: String, name: String, secondName: String) async throws -> AuthSession
    func oauth(provider: String, idToken: String, nonce: String?, name: String?, secondName: String?) async throws -> OAuthSession
    func forgotPassword(email: String) async throws
    func sendPhoneOTP(phone: String) async throws
    func verifyPhoneOTP(phone: String, code: String) async throws -> Bool
    func resendPhoneOTP(phone: String) async throws
    func logout() async throws
}
