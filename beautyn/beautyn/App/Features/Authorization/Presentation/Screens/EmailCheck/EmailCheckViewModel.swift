import Combine
import Foundation

// MARK: - EmailCheckViewModel

@MainActor
final class EmailCheckViewModel: BaseViewModel, ButtonLoadableViewModel {

    // MARK: - Transition

    struct Transition {
        let didClose: () -> Void
        let didCheckEmail: (_ email: String, _ status: EmailStatus) -> Void
        let didTapAppleSignIn: () -> Void
        let didTapGoogleSignIn: () -> Void
    }

    // MARK: - Published State

    @Published var email: String = ""
    @Published private(set) var emailError: String?
    @Published var isButtonLoading: Bool = false

    var isContinueEnabled: Bool {
        isValidEmail(email) && !isButtonLoading
    }

    // MARK: - Dependencies

    private let transition: Transition
    private let checkEmailUseCase: any CheckEmailUseCase

    // MARK: - Init

    init(transition: Transition, checkEmailUseCase: any CheckEmailUseCase) {
        self.transition = transition
        self.checkEmailUseCase = checkEmailUseCase
        super.init()
    }

    // MARK: - Intents

    func didTapContinue() {
        guard isValidEmail(email) else {
            emailError = Localization.authEmailInvalidFormat
            return
        }
        emailError = nil
        Task { await checkEmail() }
    }

    func didTapClose() { transition.didClose() }
    func didTapApple() { transition.didTapAppleSignIn() }
    func didTapGoogle() { transition.didTapGoogleSignIn() }

    // MARK: - Private

    private func checkEmail() async {
        showButtonLoader()
        do {
            let status = try await checkEmailUseCase.execute(email: email)
            hideButtonLoader()
            transition.didCheckEmail(email, status)
        } catch {
            hideButtonLoader()
            errorMessage = error.localizedDescription
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        return email.wholeMatch(of: regex) != nil
    }
}
