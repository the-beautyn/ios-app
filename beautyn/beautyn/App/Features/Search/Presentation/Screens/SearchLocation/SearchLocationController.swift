import UIKit

// MARK: - SearchLocationController

final class SearchLocationController: BaseHostingViewController<SearchLocationViewModel, SearchLocationView> {

    init(viewModel: SearchLocationViewModel) {
        let view = SearchLocationView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
