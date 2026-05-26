import UIKit

@MainActor
final class ResetPasswordCoordinator: BaseCoordinator {

    private let router: Router
    private let factory: ResetPasswordControllerFactory

    var onDidResetPassword: (() -> Void)?

    private var dismissDelegate: ResetPasswordDismissDelegate?

    init(parentAssembler: Assembler) {
        let assembler = Assembler([ResetPasswordAssembly()], parent: parentAssembler)
        let nav = UINavigationController()
        nav.delegate = NavigationBarVisibilityController.shared
        self.router = Router(navigationController: nav)
        self.factory = assembler.resetPassword.controllerFactory
    }

    override func start() {
        fatalError("Use start(email:code:) instead")
    }

    func start(email: String, code: String) {
        guard let presenter = UIApplication.topMostViewController() else { return }

        let transition = SetNewPasswordViewModel.Transition(
            didResetPassword: { [weak self] in
                self?.router.dismiss { [weak self] in
                    self?.onDidResetPassword?()
                    self?.onFinish?()
                }
            }
        )

        let vc = factory.makeSetNewPassword(email: email, code: code, transition: transition)
        router.setRoot(vc)

        let nav = router.rootViewController
        nav.modalPresentationStyle = .pageSheet

        let delegate = ResetPasswordDismissDelegate { [weak self] in
            self?.onFinish?()
        }
        nav.presentationController?.delegate = delegate
        dismissDelegate = delegate

        presenter.present(nav, animated: true)
    }
}

// MARK: - Dismiss Delegate

@MainActor
private final class ResetPasswordDismissDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
    private let onDismiss: () -> Void

    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDismiss()
    }
}
