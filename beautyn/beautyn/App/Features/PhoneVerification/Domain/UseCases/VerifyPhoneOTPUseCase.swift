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
    private let refreshCurrentUserUseCase: any RefreshCurrentUserUseCase

    init(
        repository: AuthRepository,
        sessionManager: SessionManager,
        refreshCurrentUserUseCase: any RefreshCurrentUserUseCase
    ) {
        self.repository = repository
        self.sessionManager = sessionManager
        self.refreshCurrentUserUseCase = refreshCurrentUserUseCase
    }

    func execute(phone: String, code: String) async throws -> Bool {
        let verified = try await repository.verifyPhoneOTP(phone: phone, code: code)
        if verified {
            sessionManager.markPhoneVerified()
            _ = try? await refreshCurrentUserUseCase.execute()
        }
        return verified
    }
}
