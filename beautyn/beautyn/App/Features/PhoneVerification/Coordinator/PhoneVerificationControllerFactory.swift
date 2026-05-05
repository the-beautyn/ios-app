import UIKit

// MARK: - PhoneVerificationControllerFactory

@MainActor
protocol PhoneVerificationControllerFactory {
    func makePhoneVerification(
        transition: PhoneVerificationViewModel.Transition,
        initialPhone: String?
    ) -> UIViewController
    func makePhoneCode(phone: String, transition: PhoneCodeViewModel.Transition) -> UIViewController
}

// MARK: - PhoneVerificationControllerFactoryImpl

@MainActor
final class PhoneVerificationControllerFactoryImpl: PhoneVerificationControllerFactory {

    private let assembler: AssemblerLike

    init(assembler: AssemblerLike) {
        self.assembler = assembler
    }

    func makePhoneVerification(
        transition: PhoneVerificationViewModel.Transition,
        initialPhone: String?
    ) -> UIViewController {
        let viewModel = PhoneVerificationViewModel(
            transition: transition,
            sendPhoneOTPUseCase: assembler.phoneVerification.sendPhoneOTPUseCase,
            initialPhone: initialPhone
        )
        return PhoneVerificationController(viewModel: viewModel)
    }

    func makePhoneCode(phone: String, transition: PhoneCodeViewModel.Transition) -> UIViewController {
        let viewModel = PhoneCodeViewModel(
            phone: phone,
            transition: transition,
            verifyPhoneOTPUseCase: assembler.phoneVerification.verifyPhoneOTPUseCase,
            sendPhoneOTPUseCase: assembler.phoneVerification.sendPhoneOTPUseCase
        )
        return PhoneCodeController(viewModel: viewModel)
    }
}
