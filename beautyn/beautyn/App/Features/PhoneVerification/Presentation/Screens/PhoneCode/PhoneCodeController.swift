import UIKit
import SwiftUI

// MARK: - PhoneCodeController

final class PhoneCodeController: BaseHostingViewController<PhoneCodeViewModel, PhoneCodeView> {

    init(viewModel: PhoneCodeViewModel) {
        let view = PhoneCodeView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var prefersNavigationBarHidden: Bool { false }

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
