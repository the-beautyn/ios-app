import UIKit
import SwiftUI

// MARK: - PhoneVerificationController

final class PhoneVerificationController: BaseHostingViewController<PhoneVerificationViewModel, PhoneVerificationView> {

    init(viewModel: PhoneVerificationViewModel) {
        let view = PhoneVerificationView(viewModel: viewModel)
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
        navigationItem.hidesBackButton = true
    }

    @objc private func closeTapped() {
        viewModel.didTapClose()
    }
}
