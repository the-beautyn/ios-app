import SwiftUI
import UIKit

// MARK: - SelectDateTimeController

final class SelectDateTimeController: BaseHostingViewController<SelectDateTimeViewModel, SelectDateTimeView> {

    init(viewModel: SelectDateTimeViewModel) {
        let view = SelectDateTimeView(viewModel: viewModel)
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
        navigationItem.title = Localization.bookingDatePickerTitle
        configureTransparentNavigationBar()
    }

    // MARK: - Navigation bar

    // The screen content is white and starts under the bar, so a transparent
    // appearance avoids a hairline seam. Title uses Aeonik Pro Medium 17 to match
    // the Figma navigation title, same as SelectService.
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
