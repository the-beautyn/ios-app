import UIKit

@MainActor
final class PhoneVerificationCoordinator: BaseCoordinator {

    private let router: Router
    private let factory: PhoneVerificationControllerFactory
    private let initialPhone: String?

    init(parentAssembler: Assembler, router: Router, initialPhone: String?) {
        let assembler = Assembler([PhoneVerificationAssembly()], parent: parentAssembler)
        self.router = router
        self.factory = assembler.phoneVerification.controllerFactory
        self.initialPhone = initialPhone
    }

    override func start() {
        showPhoneVerification()
    }

    private func showPhoneVerification() {
        let transition = PhoneVerificationViewModel.Transition(
            didClose: { [weak self] in self?.onFinish?() },
            didSendCode: { [weak self] phone in self?.showPhoneCode(phone: phone) }
        )
        let vc = factory.makePhoneVerification(transition: transition, initialPhone: initialPhone)
        router.push(vc, animated: true)
    }

    private func showPhoneCode(phone: String) {
        let transition = PhoneCodeViewModel.Transition(
            didClose: { [weak self] in self?.onFinish?() },
            didVerifyPhone: { [weak self] in self?.onFinish?() },
            didTapChangeNumber: { [weak self] in self?.router.pop(animated: true) }
        )
        let vc = factory.makePhoneCode(phone: phone, transition: transition)
        router.push(vc, animated: true)
    }
}
