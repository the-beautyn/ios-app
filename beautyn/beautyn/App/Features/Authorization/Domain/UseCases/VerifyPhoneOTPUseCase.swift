import Foundation

// MARK: - VerifyPhoneOTPUseCase

protocol VerifyPhoneOTPUseCase {
    func execute(phone: String, code: String) async throws -> Bool
}

// MARK: - VerifyPhoneOTPUseCaseImpl

final class VerifyPhoneOTPUseCaseImpl: VerifyPhoneOTPUseCase {

    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(phone: String, code: String) async throws -> Bool {
        try await repository.verifyPhoneOTP(phone: phone, code: code)
    }
}
