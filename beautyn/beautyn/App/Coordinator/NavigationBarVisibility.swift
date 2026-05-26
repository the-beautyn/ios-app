import UIKit

// MARK: - NavigationBarPreferring

/// A screen's preference for the shared navigation bar. Default is hidden.
protocol NavigationBarPreferring: AnyObject {
    var prefersNavigationBarHidden: Bool { get }
}

// MARK: - NavigationBarVisibilityController

/// Drives nav-bar visibility declaratively. Because `willShow` fires for both
/// pushes AND pops, the bar's state is recomputed from the incoming screen's
/// preference every time — so it auto-restores on back navigation, with no
/// per-screen `viewWillAppear` toggling. The transition's own `animated` flag
/// is threaded through, so the bar animates in lockstep with the push/pop.
final class NavigationBarVisibilityController: NSObject, UINavigationControllerDelegate {

    /// Shared, stateless instance. Held statically so assigning it to a weak
    /// `UINavigationController.delegate` keeps it alive for the app's lifetime.
    static let shared = NavigationBarVisibilityController()

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        let hidden = (viewController as? NavigationBarPreferring)?.prefersNavigationBarHidden ?? true
        navigationController.setNavigationBarHidden(hidden, animated: animated)
    }
}
