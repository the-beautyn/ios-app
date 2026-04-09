import UIKit

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
}
