import UIKit
import SwiftUI

@MainActor
final class AppCoordinator: BaseCoordinator {

    private let router: Router
    private let factory: any AppFactory
    private let assembler: AssemblerLike

    init(router: Router, factory: any AppFactory, assembler: AssemblerLike) {
        self.router = router
        self.factory = factory
        self.assembler = assembler
    }

    override func start() {
        showMain()
    }

    // MARK: - Main Flow

    private func showMain() {
        let mainFactory: any MainControllerFactory = assembler.require((any MainControllerFactory).self)
        let coordinator = MainCoordinator(router: router, factory: mainFactory)
        addChild(coordinator)
        coordinator.start()
    }
}
