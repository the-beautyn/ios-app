import UIKit

// MARK: - SavedSalonsController

final class SavedSalonsController: BaseHostingViewController<SavedSalonsViewModel, SavedSalonsView> {

    init(viewModel: SavedSalonsViewModel) {
        let view = SavedSalonsView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonDisplayMode = .minimal
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
