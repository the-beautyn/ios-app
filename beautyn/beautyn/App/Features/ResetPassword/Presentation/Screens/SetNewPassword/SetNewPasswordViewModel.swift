import Combine
import Foundation

// MARK: - SetNewPasswordViewModel

@MainActor
final class SetNewPasswordViewModel: BaseViewModel, ButtonLoadableViewModel {

    // MARK: - Transition

    struct Transition {
        let didResetPassword: () -> Void
    }

    // MARK: - Published State

    let email: String
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published private(set) var newPasswordError: String?
    @Published private(set) var confirmError: String?
    @Published private(set) var expiredLinkError: String?
    @Published private(set) var newLinkSentMessage: String?
    @Published private(set) var isRequestingNewLink: Bool = false
    @Published var isButtonLoading: Bool = false

    var isSubmitEnabled: Bool {
        PasswordValidator.validate(newPassword) == nil
            && !confirmPassword.isEmpty
            && newPassword == confirmPassword
            && !isButtonLoading
    }

    var isExpiredLinkVisible: Bool {
        expiredLinkError != nil || newLinkSentMessage != nil
    }

    // MARK: - Dependencies

    private let code: String
    private let transition: Transition
    private let resetPasswordUseCase: any ResetPasswordUseCase
    private let forgotPasswordUseCase: any ForgotPasswordUseCase
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        email: String,
        code: String,
        transition: Transition,
        resetPasswordUseCase: any ResetPasswordUseCase,
        forgotPasswordUseCase: any ForgotPasswordUseCase
    ) {
        self.email = email
        self.code = code
        self.transition = transition
        self.resetPasswordUseCase = resetPasswordUseCase
        self.forgotPasswordUseCase = forgotPasswordUseCase
        super.init()

        $newPassword
            .dropFirst()
            .sink { [weak self] value in
                self?.newPasswordError = value.isEmpty ? nil : PasswordValidator.validate(value)
            }
            .store(in: &cancellables)

        Publishers.CombineLatest($newPassword, $confirmPassword)
            .dropFirst()
            .sink { [weak self] new, confirm in
                guard let self else { return }
                if confirm.isEmpty {
                    self.confirmError = nil
                } else if new != confirm {
                    self.confirmError = Localization.setNewPasswordMismatch
                } else {
                    self.confirmError = nil
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Intents

    func didTapSubmit() {
        if let error = PasswordValidator.validate(newPassword) {
            newPasswordError = error
            return
        }
        newPasswordError = nil

        guard newPassword == confirmPassword else {
            confirmError = Localization.setNewPasswordMismatch
            return
        }
        confirmError = nil
        expiredLinkError = nil

        Task { await submit() }
    }

    func didTapRequestNewLink() {
        guard !isRequestingNewLink, newLinkSentMessage == nil else { return }
        Task { await requestNewLink() }
    }

    // MARK: - Private

    private func submit() async {
        showButtonLoader()
        do {
            try await resetPasswordUseCase.execute(token: code, newPassword: newPassword)
            hideButtonLoader()
            transition.didResetPassword()
        } catch {
            hideButtonLoader()
            if let networkError = error as? NetworkError, networkError.code == 400 {
                expiredLinkError = Localization.setNewPasswordExpiredLink
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func requestNewLink() async {
        isRequestingNewLink = true
        defer { isRequestingNewLink = false }
        do {
            try await forgotPasswordUseCase.execute(email: email)
            expiredLinkError = nil
            newLinkSentMessage = Localization.setNewPasswordNewLinkSent(email)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
