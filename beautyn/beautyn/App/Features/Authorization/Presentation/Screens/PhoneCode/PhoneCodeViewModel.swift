import Combine
import Foundation

// MARK: - PhoneCodeViewModel

@MainActor
final class PhoneCodeViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        let didClose: () -> Void
        let didVerifyPhone: () -> Void
        let didTapChangeNumber: () -> Void
    }

    // MARK: - Published State

    let phone: String
    @Published var code: String = "" {
        didSet {
            codeError = nil
            if code.count == 4 {
                Task { await verifyCode() }
            }
        }
    }
    @Published private(set) var codeError: String?

    // MARK: - Dependencies

    private let transition: Transition
    private let verifyPhoneOTPUseCase: any VerifyPhoneOTPUseCase
    private let sendPhoneOTPUseCase: any SendPhoneOTPUseCase

    // MARK: - Init

    init(phone: String, transition: Transition, verifyPhoneOTPUseCase: any VerifyPhoneOTPUseCase, sendPhoneOTPUseCase: any SendPhoneOTPUseCase) {
        self.phone = phone
        self.transition = transition
        self.verifyPhoneOTPUseCase = verifyPhoneOTPUseCase
        self.sendPhoneOTPUseCase = sendPhoneOTPUseCase
        super.init()
    }

    // MARK: - Intents

    func didTapClose() { transition.didClose() }

    func didTapResend() {
        Task { await resendCode() }
    }

    func didTapChangeNumber() {
        transition.didTapChangeNumber()
    }

    // MARK: - Private

    private func verifyCode() async {
        showLoader()
        do {
            let verified = try await verifyPhoneOTPUseCase.execute(phone: phone, code: code)
            hideLoader()
            if verified {
                transition.didVerifyPhone()
            } else {
                codeError = Localization.validationInvalidCode
            }
        } catch {
            hideLoader()
            codeError = error.localizedDescription
        }
    }

    private func resendCode() async {
        showLoader()
        do {
            try await sendPhoneOTPUseCase.execute(phone: phone)
            hideLoader()
        } catch {
            hideLoader()
            errorMessage = error.localizedDescription
        }
    }
}
