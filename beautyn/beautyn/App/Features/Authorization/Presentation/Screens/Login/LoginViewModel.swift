import Combine
import Foundation

// MARK: - LoginViewModel

@MainActor
final class LoginViewModel: BaseViewModel, ButtonLoadableViewModel {

    // MARK: - Transition

    struct Transition {
        let didClose: () -> Void
        let didLogin: () -> Void
        let didTapForgotPassword: (_ email: String) -> Void
        let didRequestPhoneVerification: () -> Void
    }

    // MARK: - Published State

    let email: String
    @Published var password: String = ""
    @Published private(set) var passwordError: String?
    @Published var isButtonLoading: Bool = false

    var isContinueEnabled: Bool {
        PasswordValidator.validate(password) == nil && !isButtonLoading
    }

    // MARK: - Dependencies

    private let transition: Transition
    private let loginUseCase: any LoginUseCase

    // MARK: - Init

    init(email: String, transition: Transition, loginUseCase: any LoginUseCase) {
        self.email = email
        self.transition = transition
        self.loginUseCase = loginUseCase
        super.init()
        $password
            .dropFirst()
            .sink { [weak self] value in
                self?.passwordError = value.isEmpty ? nil : PasswordValidator.validate(value)
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Intents

    func didTapClose() { transition.didClose() }

    func didTapContinue() {
        if let error = PasswordValidator.validate(password) {
            passwordError = error
            return
        }
        passwordError = nil
        Task { await login() }
    }

    func didTapForgotPassword() {
        transition.didTapForgotPassword(email)
    }

    // MARK: - Private

    private func login() async {
        showButtonLoader()
        do {
            let session = try await loginUseCase.execute(email: email, password: password)
            hideButtonLoader()
            if session.phoneVerificationRequired {
                transition.didRequestPhoneVerification()
            } else {
                transition.didLogin()
            }
        } catch {
            hideButtonLoader()
            showError(error)
        }
    }
}
