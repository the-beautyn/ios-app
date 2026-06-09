import UIKit

// MARK: - MyBookingsController

final class MyBookingsController: BaseHostingViewController<MyBookingsViewModel, MyBookingsView> {

    init(viewModel: MyBookingsViewModel) {
        let view = MyBookingsView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
