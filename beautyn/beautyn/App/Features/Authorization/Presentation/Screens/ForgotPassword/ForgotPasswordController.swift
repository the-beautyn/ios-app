import UIKit
import SwiftUI

// MARK: - ForgotPasswordController

final class ForgotPasswordController: BaseHostingViewController<ForgotPasswordViewModel, ForgotPasswordView> {

    init(viewModel: ForgotPasswordViewModel) {
        let view = ForgotPasswordView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            ),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = UIColor(Color.App.text)
    }

    @objc private func closeTapped() {
        viewModel.didTapClose()
    }
}
