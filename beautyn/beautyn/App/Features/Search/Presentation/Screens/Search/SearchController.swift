import UIKit

// MARK: - SearchController

final class SearchController: BaseHostingViewController<SearchViewModel, SearchView> {

    init(viewModel: SearchViewModel) {
        let view = SearchView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
