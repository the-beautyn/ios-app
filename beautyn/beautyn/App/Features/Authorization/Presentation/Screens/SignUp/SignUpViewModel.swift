import Combine
import Foundation

// MARK: - SignUpViewModel

@MainActor
final class SignUpViewModel: BaseViewModel, ButtonLoadableViewModel {

    // MARK: - Transition

    struct Transition {
        let didClose: () -> Void
        let didRegister: () -> Void
        let didRequestPhoneVerification: () -> Void
    }

    // MARK: - Published State

    let email: String
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var password: String = ""
    @Published private(set) var firstNameError: String?
    @Published private(set) var lastNameError: String?
    @Published private(set) var passwordError: String?
    @Published var isButtonLoading: Bool = false

    var isContinueEnabled: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        PasswordValidator.validate(password) == nil &&
        !isButtonLoading
    }

    // MARK: - Dependencies

    private let transition: Transition
    private let registerUseCase: any RegisterUseCase

    // MARK: - Init

    init(email: String, transition: Transition, registerUseCase: any RegisterUseCase) {
        self.email = email
        self.transition = transition
        self.registerUseCase = registerUseCase
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
        var hasError = false
        if firstName.trimmingCharacters(in: .whitespaces).isEmpty {
            firstNameError = Localization.validationRequiredField
            hasError = true
        } else { firstNameError = nil }
        if lastName.trimmingCharacters(in: .whitespaces).isEmpty {
            lastNameError = Localization.validationRequiredField
            hasError = true
        } else { lastNameError = nil }
        if let error = PasswordValidator.validate(password) {
            passwordError = error
            hasError = true
        } else { passwordError = nil }
        guard !hasError else { return }
        Task { await register() }
    }

    // MARK: - Private

    private func register() async {
        showButtonLoader()
        do {
            let session = try await registerUseCase.execute(
                email: email,
                password: password,
                name: firstName.trimmingCharacters(in: .whitespaces),
                secondName: lastName.trimmingCharacters(in: .whitespaces)
            )
            hideButtonLoader()
            if session.phoneVerificationRequired {
                transition.didRequestPhoneVerification()
            } else {
                transition.didRegister()
            }
        } catch {
            hideButtonLoader()
            showError(error)
        }
    }
}
