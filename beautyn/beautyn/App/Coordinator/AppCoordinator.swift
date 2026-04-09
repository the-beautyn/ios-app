import UIKit
import SwiftUI

@MainActor
final class AppCoordinator: BaseCoordinator {

    private let router: Router
    private let factory: any AppFactory
    private let assembler: Assembler

    init(router: Router, factory: any AppFactory, assembler: Assembler) {
        self.router = router
        self.factory = factory
        self.assembler = assembler
    }

    override func start() {
        showMain()
        let sessionManager: SessionManager = assembler.resolver.require(SessionManager.self)
        Task { sessionManager.restoreSession() }
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
        let authCoordinator = AuthCoordinator(parentAssembler: assembler)
        authCoordinator.onFinish = { [weak self] in
            self?.router.dismiss()
            self?.removeChild(authCoordinator)
            completion?()
        }
        addChild(authCoordinator)
        authCoordinator.start()

        let navVC = authCoordinator.rootViewController
        navVC.modalPresentationStyle = .pageSheet
        router.present(navVC)
    }
}
