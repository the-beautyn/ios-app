import UIKit

@MainActor
final class AuthCoordinator: BaseCoordinator {

    private let router: Router
    private let factory: AuthControllerFactory
    private let appleSignInService: AppleSignInService
    private let googleSignInService: GoogleSignInService
    private let oauthSignInUseCase: any OAuthSignInUseCase

    var rootViewController: UIViewController { router.rootViewController }

    init(parentAssembler: Assembler) {
        let assembler = Assembler([AuthAssembly()], parent: parentAssembler)
        self.router = Router(navigationController: UINavigationController())
        self.factory = assembler.auth.controllerFactory
        self.appleSignInService = assembler.app.appleSignInService
        self.googleSignInService = assembler.app.googleSignInService
        self.oauthSignInUseCase = assembler.auth.oauthSignInUseCase
    }

    override func start() {
        showEmailCheck()
    }

    // MARK: - Screens

    private func showEmailCheck() {
        let transition = EmailCheckViewModel.Transition(
            didClose: { [weak self] in
                self?.onFinish?()
            },
            didCheckEmail: { [weak self] email, status in
                switch status {
                case .notFound:
                    self?.showSignUp(email: email)
                case .password:
                    self?.showLogin(email: email)
                case .apple:
                    self?.showSocialAccountAlert(provider: "Apple")
                case .google:
                    self?.showSocialAccountAlert(provider: "Google")
                }
            },
            didTapAppleSignIn: { [weak self] in
                self?.performAppleSignIn()
            },
            didTapGoogleSignIn: { [weak self] in
                self?.performGoogleSignIn()
            }
        )
        let vc = factory.makeEmailCheck(transition: transition)
        router.setRoot(vc)
    }

    private func showLogin(email: String) {
        let transition = LoginViewModel.Transition(
            didClose: { [weak self] in
                self?.onFinish?()
            },
            didLogin: { [weak self] in
                self?.onFinish?()
            },
            didTapForgotPassword: { [weak self] email in
                self?.showForgotPassword(email: email)
            },
            didRequestPhoneVerification: { [weak self] in
                self?.showPhoneVerification()
            }
        )
        let vc = factory.makeLogin(email: email, transition: transition)
        router.push(vc)
    }

    private func showForgotPassword(email: String) {
        let transition = ForgotPasswordViewModel.Transition(
            didClose: { [weak self] in
                self?.onFinish?()
            },
            didSendResetEmail: { [weak self] in
                self?.showCheckEmailSent(email: email)
            }
        )
        let vc = factory.makeForgotPassword(email: email, transition: transition)
        router.push(vc)
    }

    private func showCheckEmailSent(email: String) {
        let transition = CheckEmailSentViewModel.Transition(
            didClose: { [weak self] in
                self?.onFinish?()
            }
        )
        let vc = factory.makeCheckEmailSent(email: email, transition: transition)
        router.push(vc)
    }

    private func showSignUp(email: String) {
        let transition = SignUpViewModel.Transition(
            didClose: { [weak self] in
                self?.onFinish?()
            },
            didRegister: { [weak self] in
                self?.onFinish?()
            },
            didRequestPhoneVerification: { [weak self] in
                self?.showPhoneVerification()
            }
        )
        let vc = factory.makeSignUp(email: email, transition: transition)
        router.push(vc)
    }

    private func showPhoneVerification() {
        let transition = PhoneVerificationViewModel.Transition(
            didClose: { [weak self] in
                self?.onFinish?()
            },
            didSendCode: { [weak self] phone in
                self?.showPhoneCode(phone: phone)
            }
        )
        let vc = factory.makePhoneVerification(transition: transition)
        router.push(vc)
    }

    private func showPhoneCode(phone: String) {
        let transition = PhoneCodeViewModel.Transition(
            didClose: { [weak self] in
                self?.onFinish?()
            },
            didVerifyPhone: { [weak self] in
                self?.onFinish?()
            },
            didTapChangeNumber: { [weak self] in
                self?.router.pop()
            }
        )
        let vc = factory.makePhoneCode(phone: phone, transition: transition)
        router.push(vc)
    }

    // MARK: - Social Auth

    private func performAppleSignIn() {
        Task {
            do {
                let result = try await appleSignInService.signIn()
                let session = try await oauthSignInUseCase.execute(
                    provider: "apple",
                    idToken: result.idToken,
                    nonce: result.nonce,
                    name: result.fullName?.givenName,
                    secondName: result.fullName?.familyName
                )
                if session.phoneVerificationRequired {
                    showPhoneVerification()
                } else {
                    onFinish?()
                }
            } catch {
                if !isCancellationError(error) {
                    // TODO: show error alert
                }
            }
        }
    }

    private func performGoogleSignIn() {
        Task {
            do {
                let presenting = router.rootViewController
                let result = try await googleSignInService.signIn(presenting: presenting)
                let session = try await oauthSignInUseCase.execute(
                    provider: "google",
                    idToken: result.idToken,
                    nonce: nil,
                    name: nil,
                    secondName: nil
                )
                if session.phoneVerificationRequired {
                    showPhoneVerification()
                } else {
                    onFinish?()
                }
            } catch {
                if !isCancellationError(error) {
                    // TODO: show error alert
                }
            }
        }
    }

    private func showSocialAccountAlert(provider: String) {
        let alert = UIAlertController(
            title: nil,
            message: Localization.authSocialAccountMessage(provider),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Localization.okButton, style: .default))
        router.rootViewController.present(alert, animated: true)
    }

    private func isCancellationError(_ error: Error) -> Bool {
        (error as NSError).code == 1001 && (error as NSError).domain == "com.apple.AuthenticationServices.AuthorizationError"
    }
}
