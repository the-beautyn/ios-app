import Combine
import Foundation

// MARK: - ChangePasswordViewModel

@MainActor
final class ChangePasswordViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        let didFinishChanging: () -> Void
    }

    // MARK: - Published

    @Published var oldPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    @Published private(set) var oldPasswordError: String?
    @Published private(set) var newPasswordError: String?
    @Published private(set) var confirmPasswordError: String?

    // MARK: - Computed

    var isEnabled: Bool {
        !oldPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        PasswordValidator.validate(newPassword) == nil &&
        newPassword != oldPassword &&
        newPassword == confirmPassword &&
        !isLoading
    }

    // MARK: - Dependencies

    private let transition: Transition
    private let changePasswordUseCase: any ChangePasswordUseCase
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(transition: Transition, changePasswordUseCase: any ChangePasswordUseCase) {
        self.transition = transition
        self.changePasswordUseCase = changePasswordUseCase
        super.init()

        $newPassword
            .combineLatest($oldPassword)
            .dropFirst()
            .sink { [weak self] new, old in
                guard !new.isEmpty else {
                    self?.newPasswordError = nil
                    return
                }
                if !old.isEmpty, new == old {
                    self?.newPasswordError = Localization.validationNewPasswordSameAsOld
                    return
                }
                self?.newPasswordError = PasswordValidator.validate(new)
            }
            .store(in: &cancellables)

        $confirmPassword
            .combineLatest($newPassword)
            .dropFirst()
            .sink { [weak self] confirm, new in
                guard !confirm.isEmpty, !new.isEmpty else {
                    self?.confirmPasswordError = nil
                    return
                }
                self?.confirmPasswordError = confirm != new
                    ? Localization.validationPasswordsDontMatch
                    : nil
            }
            .store(in: &cancellables)
    }

    // MARK: - Intents

    func didTapSubmit() {
        guard isEnabled else { return }
        Task { [weak self] in
            guard let self else { return }
            self.oldPasswordError = nil
            self.showLoader()
            do {
                try await self.changePasswordUseCase.execute(
                    currentPassword: self.oldPassword,
                    newPassword: self.newPassword
                )
                self.hideLoader()
                showSuccess(Localization.profileChangePasswordSuccess, scope: .global)
                self.transition.didFinishChanging()
            } catch let error as NetworkError where error.code == 401 {
                self.hideLoader()
                self.oldPasswordError = Localization.validationOldPasswordIncorrect
            } catch {
                self.hideLoader()
                self.showError(error)
            }
        }
    }
}
