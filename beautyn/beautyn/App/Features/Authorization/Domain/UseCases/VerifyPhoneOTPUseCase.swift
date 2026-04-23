import Foundation

// MARK: - VerifyPhoneOTPUseCase

protocol VerifyPhoneOTPUseCase {
    func execute(phone: String, code: String) async throws -> Bool
}

// MARK: - VerifyPhoneOTPUseCaseImpl

@MainActor
final class VerifyPhoneOTPUseCaseImpl: VerifyPhoneOTPUseCase {

    private let repository: AuthRepository
    private let sessionManager: SessionManager

    init(repository: AuthRepository, sessionManager: SessionManager) {
        self.repository = repository
        self.sessionManager = sessionManager
    }

    func execute(phone: String, code: String) async throws -> Bool {
        let verified = try await repository.verifyPhoneOTP(phone: phone, code: code)
        if verified {
            sessionManager.markPhoneVerified()
        }
        return verified
    }
}
