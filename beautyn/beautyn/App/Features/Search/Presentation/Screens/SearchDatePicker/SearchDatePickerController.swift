import UIKit

// MARK: - SearchDatePickerController

final class SearchDatePickerController: BaseHostingViewController<SearchDatePickerViewModel, SearchDatePickerView> {

    init(viewModel: SearchDatePickerViewModel) {
        let view = SearchDatePickerView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
