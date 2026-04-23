import Combine
import Foundation

// MARK: - PhoneVerificationViewModel

@MainActor
final class PhoneVerificationViewModel: BaseViewModel, ButtonLoadableViewModel {

    // MARK: - Transition

    struct Transition {
        let didClose: () -> Void
        let didSendCode: (_ phone: String) -> Void
    }

    // MARK: - Published State

    @Published var phoneNumber: String = ""
    @Published private(set) var phoneError: String?
    @Published var isButtonLoading: Bool = false
    var countryCode: String = "+38"

    var isSendEnabled: Bool {
        isValidPhone && !isButtonLoading
    }

    // MARK: - Dependencies

    private let transition: Transition
    private let sendPhoneOTPUseCase: any SendPhoneOTPUseCase

    // MARK: - Init

    init(transition: Transition, sendPhoneOTPUseCase: any SendPhoneOTPUseCase) {
        self.transition = transition
        self.sendPhoneOTPUseCase = sendPhoneOTPUseCase
        super.init()
    }

    // MARK: - Intents

    func didTapClose() { transition.didClose() }

    func didTapSendCode() {
        guard isValidPhone else {
            phoneError = Localization.validationInvalidPhone
            return
        }
        phoneError = nil
        Task { await sendCode() }
    }

    // MARK: - Private

    private var isValidPhone: Bool {
        let digits = phoneNumber.filter(\.isNumber)
        return digits.count >= 9
    }

    private var fullPhoneNumber: String {
        countryCode + phoneNumber.filter(\.isNumber)
    }

    private func sendCode() async {
        showButtonLoader()
        do {
            try await sendPhoneOTPUseCase.execute(phone: fullPhoneNumber)
            hideButtonLoader()
            transition.didSendCode(fullPhoneNumber)
        } catch {
            hideButtonLoader()
            errorMessage = error.localizedDescription
        }
    }
}
