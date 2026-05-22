import UIKit

@MainActor
final class Router {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    var rootViewController: UIViewController {
        navigationController
    }

    func setRoot(_ viewController: UIViewController, animated: Bool = false) {
        navigationController.setViewControllers([viewController], animated: animated)
    }

    func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(viewController, animated: animated)
    }

    func pop(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }

    func popToRoot(animated: Bool = true) {
        navigationController.popToRootViewController(animated: animated)
    }

    func popTo<T: UIViewController>(_ type: T.Type, animated: Bool = true) {
        guard let target = navigationController.viewControllers.last(where: { $0 is T }) else {
            return
        }
        navigationController.popToViewController(target, animated: animated)
    }

    func present(
        _ viewController: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        navigationController.present(viewController, animated: animated, completion: completion)
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController.dismiss(animated: animated, completion: completion)
    }
}
