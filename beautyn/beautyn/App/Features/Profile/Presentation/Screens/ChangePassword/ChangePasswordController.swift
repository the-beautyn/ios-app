import UIKit
import SwiftUI
import Combine

// MARK: - ChangePasswordController

final class ChangePasswordController: BaseHostingViewController<ChangePasswordViewModel, ChangePasswordView> {

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ChangePasswordViewModel) {
        let view = ChangePasswordView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.profileChangePasswordTitle
        navigationItem.backButtonDisplayMode = .minimal
        setupSubmitButton()
        bindSubmitButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Submit button

    private func setupSubmitButton() {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "checkmark"),
            style: .prominent,
            target: self,
            action: #selector(submitTapped)
        )
        button.tintColor = UIColor(Color.App.brown2)
        navigationItem.rightBarButtonItem = button
        updateSubmitButton()
    }

    private func bindSubmitButton() {
        viewModel.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async { self?.updateSubmitButton() }
            }
            .store(in: &cancellables)
    }

    private func updateSubmitButton() {
        let isEnabled = viewModel.isEnabled
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled
        navigationItem.rightBarButtonItem?.tintColor = UIColor(Color.App.brown2)
            .withAlphaComponent(isEnabled ? 1.0 : 0.5)
    }

    @objc private func submitTapped() {
        viewModel.didTapSubmit()
    }
}
