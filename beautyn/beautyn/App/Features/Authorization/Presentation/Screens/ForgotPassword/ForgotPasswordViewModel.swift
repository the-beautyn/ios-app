import Combine
import Foundation

// MARK: - ForgotPasswordViewModel

@MainActor
final class ForgotPasswordViewModel: BaseViewModel, ButtonLoadableViewModel {

    // MARK: - Transition

    struct Transition {
        let didClose: () -> Void
        let didSendResetEmail: () -> Void
    }

    // MARK: - Published State

    @Published var email: String
    @Published private(set) var emailError: String?
    @Published var isButtonLoading: Bool = false

    var isSendEnabled: Bool {
        isValidEmail(email) && !isButtonLoading
    }

    // MARK: - Dependencies

    private let transition: Transition
    private let forgotPasswordUseCase: any ForgotPasswordUseCase

    // MARK: - Init

    init(email: String, transition: Transition, forgotPasswordUseCase: any ForgotPasswordUseCase) {
        self.email = email
        self.transition = transition
        self.forgotPasswordUseCase = forgotPasswordUseCase
        super.init()
    }

    // MARK: - Intents

    func didTapClose() { transition.didClose() }

    func didTapSend() {
        guard isValidEmail(email) else {
            emailError = Localization.authEmailInvalidFormat
            return
        }
        emailError = nil
        Task { await sendReset() }
    }

    // MARK: - Private

    private func sendReset() async {
        showButtonLoader()
        do {
            try await forgotPasswordUseCase.execute(email: email)
            hideButtonLoader()
            transition.didSendResetEmail()
        } catch {
            hideButtonLoader()
            showError(error)
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        return email.wholeMatch(of: regex) != nil
    }
}
