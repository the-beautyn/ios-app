import UIKit

// MARK: - ServiceTypeFilterController

final class ServiceTypeFilterController: BaseHostingViewController<ServiceTypeFilterViewModel, ServiceTypeFilterView> {

    init(viewModel: ServiceTypeFilterViewModel) {
        let view = ServiceTypeFilterView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
