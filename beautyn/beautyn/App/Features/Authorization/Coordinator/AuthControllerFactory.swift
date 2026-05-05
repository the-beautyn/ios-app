import UIKit

// MARK: - AuthControllerFactory

@MainActor
protocol AuthControllerFactory {
    func makeEmailCheck(transition: EmailCheckViewModel.Transition) -> UIViewController
    func makeLogin(email: String, transition: LoginViewModel.Transition) -> UIViewController
    func makeForgotPassword(email: String, transition: ForgotPasswordViewModel.Transition) -> UIViewController
    func makeCheckEmailSent(email: String, transition: CheckEmailSentViewModel.Transition) -> UIViewController
    func makeSignUp(email: String, transition: SignUpViewModel.Transition) -> UIViewController
}

// MARK: - AuthControllerFactoryImpl

@MainActor
final class AuthControllerFactoryImpl: AuthControllerFactory {

    private let assembler: AssemblerLike

    init(assembler: AssemblerLike) {
        self.assembler = assembler
    }

    func makeEmailCheck(transition: EmailCheckViewModel.Transition) -> UIViewController {
        let viewModel = EmailCheckViewModel(transition: transition, checkEmailUseCase: assembler.auth.checkEmailUseCase)
        return EmailCheckController(viewModel: viewModel)
    }

    func makeLogin(email: String, transition: LoginViewModel.Transition) -> UIViewController {
        let viewModel = LoginViewModel(email: email, transition: transition, loginUseCase: assembler.auth.loginUseCase)
        return LoginController(viewModel: viewModel)
    }

    func makeForgotPassword(email: String, transition: ForgotPasswordViewModel.Transition) -> UIViewController {
        let viewModel = ForgotPasswordViewModel(email: email, transition: transition, forgotPasswordUseCase: assembler.app.forgotPasswordUseCase)
        return ForgotPasswordController(viewModel: viewModel)
    }

    func makeCheckEmailSent(email: String, transition: CheckEmailSentViewModel.Transition) -> UIViewController {
        let viewModel = CheckEmailSentViewModel(email: email, transition: transition)
        return CheckEmailSentController(viewModel: viewModel)
    }

    func makeSignUp(email: String, transition: SignUpViewModel.Transition) -> UIViewController {
        let viewModel = SignUpViewModel(email: email, transition: transition, registerUseCase: assembler.auth.registerUseCase)
        return SignUpController(viewModel: viewModel)
    }
}
