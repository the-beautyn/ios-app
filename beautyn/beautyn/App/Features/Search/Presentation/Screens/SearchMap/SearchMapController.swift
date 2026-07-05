import UIKit

// MARK: - SearchMapController

final class SearchMapController: BaseHostingViewController<SearchMapViewModel, SearchMapView> {

    init(viewModel: SearchMapViewModel) {
        let view = SearchMapView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
