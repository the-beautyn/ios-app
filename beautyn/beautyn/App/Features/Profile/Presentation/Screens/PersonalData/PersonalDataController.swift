import UIKit

// MARK: - PersonalDataController

final class PersonalDataController: BaseHostingViewController<PersonalDataViewModel, PersonalDataView> {

    init(viewModel: PersonalDataViewModel) {
        let view = PersonalDataView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var prefersNavigationBarHidden: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonDisplayMode = .minimal
    }
}
