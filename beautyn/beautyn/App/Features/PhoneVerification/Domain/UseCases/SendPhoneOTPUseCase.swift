import Foundation

// MARK: - SendPhoneOTPUseCase

protocol SendPhoneOTPUseCase {
    func execute(phone: String) async throws
}

// MARK: - SendPhoneOTPUseCaseImpl

final class SendPhoneOTPUseCaseImpl: SendPhoneOTPUseCase {

    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(phone: String) async throws {
        try await repository.sendPhoneOTP(phone: phone)
    }
}
