import UIKit
import GoogleSignIn

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

        for userActivity in connectionOptions.userActivities {
            handleUserActivity(userActivity)
        }

        for urlContext in connectionOptions.urlContexts {
            GIDSignIn.sharedInstance.handle(urlContext.url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        GIDSignIn.sharedInstance.handle(url)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        handleUserActivity(userActivity)
    }

    // MARK: - Private

    private func setupWindow(with scene: UIWindowScene) {
        let window = UIWindow(windowScene: scene)

        let rootNav = UINavigationController()
        rootNav.setNavigationBarHidden(true, animated: false)
        let router = Router(navigationController: rootNav)
        let assembler = AppDelegate.shared.assembler
        let coordinator = AppCoordinator(router: router, assembler: assembler)

        appCoordinator = coordinator
        window.rootViewController = router.rootViewController
        self.window = window
        window.makeKeyAndVisible()

        coordinator.start()
    }

    private func handleUserActivity(_ userActivity: NSUserActivity) {
        guard
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL
        else { return }

        let deepLinkingService = AppDelegate.shared.assembler.app.deepLinkingService
        deepLinkingService.handle(url: url)
    }
}
