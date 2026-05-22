import UIKit
import SwiftUI

// MARK: - MainTabCoordinator
//
// Uses a system `UITabBarController` — on iOS 26+ the tab bar automatically
// gets the Liquid Glass treatment. Each tab is a `UINavigationController`
// with its own router so navigation stacks are preserved across tab
// switches.
//
// Profile tab is auth-gated: `shouldSelect` returns `false` and invokes
// `onRequireAuth` when the user is not authenticated.

@MainActor
final class MainTabCoordinator: BaseCoordinator {

    private let router: Router
    private let parentAssembler: Assembler

    private var homeCoordinator: HomeCoordinator!
    private var profileCoordinator: ProfileCoordinator!
    private var homeNav: UINavigationController!
    private var profileNav: UINavigationController!
    private var searchNav: UINavigationController!
    private var bookingsNav: UINavigationController!

    private let tabBarController = MainTabBarController()

    var onRequireAuth: (() -> Void)?

    init(router: Router, parentAssembler: Assembler) {
        self.router = router
        self.parentAssembler = parentAssembler
    }

    override func start() {
        // Outlined icons for both states — active state is communicated by
        // color (brown1) via the tab bar's appearance config.
        homeNav = makeTabNav(
            title: Localization.tabHome,
            icon: UIImage(resource: .homeTab)
        )
        searchNav = makeStubTab(
            title: Localization.tabSearch,
            icon: UIImage(resource: .searchTab)
        )
        bookingsNav = makeStubTab(
            title: Localization.tabBookings,
            icon: UIImage(resource: .bookingTab)
        )
        profileNav = makeTabNav(
            title: Localization.tabProfile,
            icon: UIImage(resource: .profileTab)
        )

        homeCoordinator = HomeCoordinator(
            router: Router(navigationController: homeNav),
            parentAssembler: parentAssembler
        )
        homeCoordinator.onRequireAuth = { [weak self] in
            self?.onRequireAuth?()
        }
        addChild(homeCoordinator)
        homeCoordinator.start()

        profileCoordinator = ProfileCoordinator(
            router: Router(navigationController: profileNav),
            parentAssembler: parentAssembler
        )
        addChild(profileCoordinator)
        profileCoordinator.start()

        tabBarController.viewControllers = [homeNav, searchNav, bookingsNav, profileNav]
        tabBarController.onShouldSelect = { [weak self] viewController in
            guard let self else { return true }
            if viewController === self.profileNav, !self.isAuthenticated {
                self.onRequireAuth?()
                return false
            }
            return true
        }

        router.setRoot(tabBarController, animated: false)
    }

    func selectHomeTab() {
        guard let homeNav else { return }
        // Profile-stack screens like ProfileSettings use
        // `hidesBottomBarWhenPushed`. If we switch tabs while one is still on
        // top, the tab bar stays hidden on the new tab. Pop the profile stack
        // first so visibility recomputes against the profile root.
        profileNav?.popToRootViewController(animated: false)
        tabBarController.selectedViewController = homeNav
    }

    // MARK: - Private

    private var isAuthenticated: Bool {
        parentAssembler.app.sessionManager.isAuthenticated
    }

    private func makeTabNav(
        title: String,
        icon: UIImage
    ) -> UINavigationController {
        let nav = UINavigationController()
        nav.setNavigationBarHidden(true, animated: false)
        nav.tabBarItem = makeTabItem(title: title, icon: icon)
        return nav
    }

    private func makeStubTab(
        title: String,
        icon: UIImage
    ) -> UINavigationController {
        let placeholder = UIHostingController(rootView: ComingSoonView(title: title))
        let nav = UINavigationController(rootViewController: placeholder)
        nav.setNavigationBarHidden(true, animated: false)
        nav.tabBarItem = makeTabItem(title: title, icon: icon)
        return nav
    }

    // iOS 26 Liquid Glass ignores `UITabBarAppearance.stackedLayoutAppearance`
    // item colors and the legacy `tintColor` / `unselectedItemTintColor`. We
    // bake our colors into each item directly:
    //   - Images are pre-tinted with `.alwaysOriginal` so the tab bar's tint
    //     system is bypassed entirely.
    //   - Per-item `setTitleTextAttributes` drives the label font + color and
    //     takes precedence over any appearance-level attributes.
    private func makeTabItem(title: String, icon: UIImage) -> UITabBarItem {
        let unselectedColor = UIColor(Color.App.gray2)
        let selectedColor = UIColor(Color.App.brown1)
        let font = UIFont(name: AeonikPro.medium, size: 10)
            ?? UIFont.systemFont(ofSize: 10, weight: .medium)

        let unselectedImage = icon.withTintColor(unselectedColor, renderingMode: .alwaysOriginal)
        let selectedImage = icon.withTintColor(selectedColor, renderingMode: .alwaysOriginal)

        let item = UITabBarItem(
            title: title,
            image: unselectedImage,
            selectedImage: selectedImage
        )
        // Font only — color comes from the tab bar's tintColor /
        // unselectedItemTintColor, which Liquid Glass honors where per-item
        // `foregroundColor` attributes do not.
        item.setTitleTextAttributes([.font: font], for: .normal)
        item.setTitleTextAttributes([.font: font], for: .selected)
        return item
    }
}

// MARK: - MainTabBarController

@MainActor
final class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    /// Asked for each tap. Returning `false` blocks the switch (used for the
    /// auth-gated Profile tab).
    var onShouldSelect: ((UIViewController) -> Bool)?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        // Icons are pre-tinted via `.alwaysOriginal` in `makeTabItem`, so
        // the tint only drives label colors. iOS 26 Liquid Glass currently
        // ignores title `foregroundColor` attributes (both per-item and via
        // `UITabBarAppearance`) — leaving this here as the baseline while
        // the title color stays the system default.
        tabBar.tintColor = UIColor(Color.App.brown1)
        tabBar.unselectedItemTintColor = UIColor(Color.App.gray2)
    }

    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        onShouldSelect?(viewController) ?? true
    }
}

// MARK: - Stub placeholder for Search / Bookings tabs

struct ComingSoonView: View {
    let title: String

    var body: some View {
        VStack(spacing: CGFloat.Spacing.sm) {
            Text(title)
                .font(.App.title2Medium)
                .tracking(CGFloat.Tracking.title2)
                .foregroundStyle(Color.App.text)
            Text("Coming soon")
                .font(.App.body)
                .foregroundStyle(Color.App.gray2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.App.backgroundLight)
    }
}
