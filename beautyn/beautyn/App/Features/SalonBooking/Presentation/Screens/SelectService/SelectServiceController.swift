import SwiftUI
import UIKit

// MARK: - SelectServiceController

final class SelectServiceController: BaseHostingViewController<SelectServiceViewModel, SelectServiceView> {

    init(viewModel: SelectServiceViewModel) {
        let view = SelectServiceView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var prefersNavigationBarHidden: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Localization.selectServiceTitle
        configureTransparentNavigationBar()
        // Back navigation uses the system back button (a glass chevron on
        // iOS 26), matching SalonProfile — a custom leftBarButtonItem would
        // render a second, duplicate back control.
    }

    // MARK: - Navigation bar

    // The screen content is white and starts right under the bar, so a
    // transparent appearance avoids a hairline/shadow seam. The title uses the
    // app's Aeonik Pro Medium 17 to match the Figma navigation title.
    private func configureTransparentNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .font: UIFont(name: AeonikPro.medium, size: 17) ?? .systemFont(ofSize: 17, weight: .medium),
            .foregroundColor: UIColor(Color.App.text)
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
}
