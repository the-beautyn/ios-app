import UIKit

extension UIApplication {
    @MainActor
    static func topMostViewController() -> UIViewController? {
        let keyWindow = shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })

        guard let rootViewController = keyWindow?.rootViewController else { return nil }
        return topMostViewController(from: rootViewController)
    }

    @MainActor
    private static func topMostViewController(from controller: UIViewController) -> UIViewController {
        if let presented = controller.presentedViewController {
            return topMostViewController(from: presented)
        }
        if let navigation = controller as? UINavigationController,
           let visible = navigation.visibleViewController {
            return topMostViewController(from: visible)
        }
        if let tab = controller as? UITabBarController,
           let selected = tab.selectedViewController {
            return topMostViewController(from: selected)
        }
        return controller
    }
}
