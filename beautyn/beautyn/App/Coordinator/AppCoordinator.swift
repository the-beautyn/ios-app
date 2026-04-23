import Combine
import UIKit
import SwiftUI

@MainActor
final class AppCoordinator: BaseCoordinator {

    private let router: Router
    private let assembler: Assembler
    private var cancellables = Set<AnyCancellable>()
    private weak var authCoordinator: AuthCoordinator?

    init(router: Router, assembler: Assembler) {
        self.router = router
        self.assembler = assembler
    }

    override func start() {
        showMain()
        let sessionManager = assembler.app.sessionManager
        sessionManager.restoreSession()

        subscribeToDeepLinks()

        guard sessionManager.authState == .authenticated else { return }
        Task { try? await assembler.app.refreshTokenUseCase.execute() }
    }

    // MARK: - Main Flow

    private func showMain() {
        let coordinator = MainCoordinator(router: router, parentAssembler: assembler)
        coordinator.onRequireAuth = { [weak self] in
            self?.showAuth()
        }
        addChild(coordinator)
        coordinator.start()
    }

    // MARK: - Auth Flow

    func showAuth(completion: (() -> Void)? = nil) {
        let coordinator = makeAuthCoordinator(completion: completion)
        coordinator.start()

        let navVC = coordinator.rootViewController
        navVC.modalPresentationStyle = .pageSheet
        router.present(navVC)
    }

    private func makeAuthCoordinator(completion: (() -> Void)?) -> AuthCoordinator {
        let coordinator = AuthCoordinator(parentAssembler: assembler)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.router.dismiss()
            self.removeChild(coordinator)
            completion?()
        }
        authCoordinator = coordinator
        addChild(coordinator)
        return coordinator
    }

    // MARK: - Deep Links

    private func subscribeToDeepLinks() {
        let deepLinkingService = assembler.app.deepLinkingService
        deepLinkingService.resetPasswordPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                self?.handleResetPasswordDeepLink(model)
            }
            .store(in: &cancellables)
    }

    private func handleResetPasswordDeepLink(_ model: ResetPasswordLinkModel) {
        let coordinator = ResetPasswordCoordinator(parentAssembler: assembler)
        coordinator.onDidResetPassword = { [weak self] in
            guard let self,
                  let auth = self.authCoordinator,
                  auth.rootViewController.view.window != nil
            else { return }
            self.router.dismiss()
            self.removeChild(auth)
            self.authCoordinator = nil
        }
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.removeChild(coordinator)
        }
        addChild(coordinator)
        coordinator.start(email: model.email, code: model.code)
    }
}
