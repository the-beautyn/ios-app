import UIKit
import SwiftUI

// MARK: - SearchSortController

final class SearchSortController: BaseHostingViewController<SearchSortViewModel, SearchSortView> {

    init(viewModel: SearchSortViewModel) {
        let view = SearchSortView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
        // Transparent full-screen container: the AppBottomSheet inside the
        // view draws the dim + the anchored fixed-height sheet itself.
        modalPresentationStyle = .overFullScreen
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}
