import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        setupWindow(with: windowScene)
    }

    // MARK: - Private

    private func setupWindow(with scene: UIWindowScene) {
        let window = UIWindow(windowScene: scene)

        let router = Router(navigationController: UINavigationController())
        let assembler = AppDelegate.shared.assembler
        let factory = assembler.resolver.require((any AppFactory).self)
        let coordinator = AppCoordinator(router: router, factory: factory)

        appCoordinator = coordinator
        window.rootViewController = router.rootViewController
        self.window = window
        window.makeKeyAndVisible()

        coordinator.start()
    }
}
