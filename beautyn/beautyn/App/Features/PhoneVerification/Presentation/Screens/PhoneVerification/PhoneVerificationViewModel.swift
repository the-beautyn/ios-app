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
    var countryCode: String = "+380"

    var isSendEnabled: Bool {
        isValidPhone && !isButtonLoading
    }

    // MARK: - Dependencies

    private let transition: Transition
    private let sendPhoneOTPUseCase: any SendPhoneOTPUseCase

    // MARK: - Init

    init(
        transition: Transition,
        sendPhoneOTPUseCase: any SendPhoneOTPUseCase,
        initialPhone: String? = nil
    ) {
        self.transition = transition
        self.sendPhoneOTPUseCase = sendPhoneOTPUseCase
        super.init()
        if let initialPhone {
            phoneNumber = Self.stripCountryCode(from: initialPhone)
        }
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
        return digits.count == 9
    }

    private var fullPhoneNumber: String {
        countryCode + phoneNumber.filter(\.isNumber)
    }

    private static func stripCountryCode(from phone: String) -> String {
        let digits = phone.filter(\.isNumber)
        if digits.count >= 12, digits.hasPrefix("380") {
            return String(digits.suffix(digits.count - 3))
        }
        return digits
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
