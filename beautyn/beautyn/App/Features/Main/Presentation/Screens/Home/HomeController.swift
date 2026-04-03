import UIKit

// MARK: - HomeController

final class HomeController: BaseHostingViewController<HomeViewModel, HomeView> {

    init(viewModel: HomeViewModel) {
        let view = HomeView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
