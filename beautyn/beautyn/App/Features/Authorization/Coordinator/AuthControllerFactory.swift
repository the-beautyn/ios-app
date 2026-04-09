import UIKit

// MARK: - AuthControllerFactory

@MainActor
protocol AuthControllerFactory {
    func makeEmailCheck(transition: EmailCheckViewModel.Transition) -> UIViewController
    func makeLogin(email: String, transition: LoginViewModel.Transition) -> UIViewController
    func makeForgotPassword(email: String, transition: ForgotPasswordViewModel.Transition) -> UIViewController
    func makeSignUp(email: String, transition: SignUpViewModel.Transition) -> UIViewController
    func makePhoneVerification(transition: PhoneVerificationViewModel.Transition) -> UIViewController
    func makePhoneCode(phone: String, transition: PhoneCodeViewModel.Transition) -> UIViewController
}

// MARK: - AuthControllerFactoryImpl

@MainActor
final class AuthControllerFactoryImpl: AuthControllerFactory {

    private let assembler: AssemblerLike

    init(assembler: AssemblerLike) {
        self.assembler = assembler
    }

    func makeEmailCheck(transition: EmailCheckViewModel.Transition) -> UIViewController {
        let useCase: any CheckEmailUseCase = assembler.require((any CheckEmailUseCase).self)
        let viewModel = EmailCheckViewModel(transition: transition, checkEmailUseCase: useCase)
        return EmailCheckController(viewModel: viewModel)
    }

    func makeLogin(email: String, transition: LoginViewModel.Transition) -> UIViewController {
        let useCase: any LoginUseCase = assembler.require((any LoginUseCase).self)
        let viewModel = LoginViewModel(email: email, transition: transition, loginUseCase: useCase)
        return LoginController(viewModel: viewModel)
    }

    func makeForgotPassword(email: String, transition: ForgotPasswordViewModel.Transition) -> UIViewController {
        let useCase: any ForgotPasswordUseCase = assembler.require((any ForgotPasswordUseCase).self)
        let viewModel = ForgotPasswordViewModel(email: email, transition: transition, forgotPasswordUseCase: useCase)
        return ForgotPasswordController(viewModel: viewModel)
    }

    func makeSignUp(email: String, transition: SignUpViewModel.Transition) -> UIViewController {
        let useCase: any RegisterUseCase = assembler.require((any RegisterUseCase).self)
        let viewModel = SignUpViewModel(email: email, transition: transition, registerUseCase: useCase)
        return SignUpController(viewModel: viewModel)
    }

    func makePhoneVerification(transition: PhoneVerificationViewModel.Transition) -> UIViewController {
        let useCase: any SendPhoneOTPUseCase = assembler.require((any SendPhoneOTPUseCase).self)
        let viewModel = PhoneVerificationViewModel(transition: transition, sendPhoneOTPUseCase: useCase)
        return PhoneVerificationController(viewModel: viewModel)
    }

    func makePhoneCode(phone: String, transition: PhoneCodeViewModel.Transition) -> UIViewController {
        let verifyUseCase: any VerifyPhoneOTPUseCase = assembler.require((any VerifyPhoneOTPUseCase).self)
        let sendUseCase: any SendPhoneOTPUseCase = assembler.require((any SendPhoneOTPUseCase).self)
        let viewModel = PhoneCodeViewModel(phone: phone, transition: transition, verifyPhoneOTPUseCase: verifyUseCase, sendPhoneOTPUseCase: sendUseCase)
        return PhoneCodeController(viewModel: viewModel)
    }
}
