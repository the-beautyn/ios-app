import Combine
import SwiftUI
import UIKit

// MARK: - SetNewPasswordController

final class SetNewPasswordController: BaseHostingViewController<SetNewPasswordViewModel, SetNewPasswordView> {

    private var cancellables = Set<AnyCancellable>()
    private var submitItem: UIBarButtonItem?

    init(viewModel: SetNewPasswordViewModel) {
        let view = SetNewPasswordView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var prefersNavigationBarHidden: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        bindViewModel()
    }

    // MARK: - Configuration

    private func configureNavigationBar() {
        navigationItem.title = Localization.setNewPasswordTitle

        let item = UIBarButtonItem(
            image: UIImage(systemName: "checkmark"),
            style: .prominent,
            target: self,
            action: #selector(submitTapped)
        )
        item.tintColor = UIColor(Color.App.brown2)
        submitItem = item
        navigationItem.rightBarButtonItem = item
    }

    private func bindViewModel() {
        viewModel.$isButtonLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.applyLoadingState(isLoading)
            }
            .store(in: &cancellables)

        viewModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateSubmitEnabledState()
                }
            }
            .store(in: &cancellables)

        updateSubmitEnabledState()
    }

    private func updateSubmitEnabledState() {
        submitItem?.isEnabled = viewModel.isSubmitEnabled
    }

    private func applyLoadingState(_ isLoading: Bool) {
        if isLoading {
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.color = UIColor(Color.App.brown2)
            indicator.startAnimating()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
        } else if let submitItem {
            navigationItem.rightBarButtonItem = submitItem
            updateSubmitEnabledState()
        }
    }

    // MARK: - Actions

    @objc private func submitTapped() {
        viewModel.didTapSubmit()
    }
}
