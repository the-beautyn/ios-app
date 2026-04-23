import UIKit

// MARK: - ResetPasswordControllerFactory

@MainActor
protocol ResetPasswordControllerFactory {
    func makeSetNewPassword(email: String, code: String, transition: SetNewPasswordViewModel.Transition) -> UIViewController
}

// MARK: - ResetPasswordControllerFactoryImpl

@MainActor
final class ResetPasswordControllerFactoryImpl: ResetPasswordControllerFactory {

    private let assembler: AssemblerLike

    init(assembler: AssemblerLike) {
        self.assembler = assembler
    }

    func makeSetNewPassword(email: String, code: String, transition: SetNewPasswordViewModel.Transition) -> UIViewController {
        let viewModel = SetNewPasswordViewModel(
            email: email,
            code: code,
            transition: transition,
            resetPasswordUseCase: assembler.app.resetPasswordUseCase,
            forgotPasswordUseCase: assembler.app.forgotPasswordUseCase
        )
        return SetNewPasswordController(viewModel: viewModel)
    }
}
