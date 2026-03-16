import UIKit
import SwiftUI

@MainActor
final class AppCoordinator: BaseCoordinator {

    private let router: Router
    private let factory: any AppFactory

    init(router: Router, factory: any AppFactory) {
        self.router = router
        self.factory = factory
    }

    override func start() {
        showLaunch()
    }

    // MARK: - Private

    private func showLaunch() {
        let vc = makePlaceholderViewController()
        router.setRoot(vc, animated: false)
    }

    private func makePlaceholderViewController() -> UIViewController {
        let view = LaunchPlaceholderView()
        let host = UIHostingController(rootView: view)
        host.view.backgroundColor = .systemBackground
        return host
    }
}

// MARK: - LaunchPlaceholderView

private struct LaunchPlaceholderView: View {
    var body: some View {
        VStack(spacing: CGFloat.Spacing.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(Color.App.red)

            Text("beautyn")
                .font(.App.largeTitleBold)
                .tracking(0)
                .foregroundStyle(Color.App.text)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.App.backgroundLight)
    }
}
