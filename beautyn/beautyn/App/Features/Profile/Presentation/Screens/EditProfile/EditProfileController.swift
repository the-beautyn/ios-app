import UIKit
import SwiftUI
import Combine

// MARK: - EditProfileController
//
// Hosts `EditProfileView` and owns the UIKit navigation bar:
//   • title from `Localization.editProfileTitle`
//   • system back button (minimal chevron) — pop is handled by UINavigationController
//   • trailing checkmark `UIBarButtonItem` shown only while `viewModel.canSubmit`
//     is true; tapping it forwards to `viewModel.didTapConfirm()`.

final class EditProfileController: BaseHostingViewController<EditProfileViewModel, EditProfileView> {

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: EditProfileViewModel) {
        let view = EditProfileView(viewModel: viewModel)
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
        title = Localization.editProfileTitle
        navigationItem.backButtonDisplayMode = .minimal
        bindConfirmButton()
        updateConfirmButton()
    }

    // MARK: - Confirm button

    private func bindConfirmButton() {
        // `objectWillChange` fires on every @Published change in the view
        // model (form fields, isLoading, etc.) — defer to the next runloop
        // tick so we read the post-change value of `canSubmit`.
        viewModel.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async { self?.updateConfirmButton() }
            }
            .store(in: &cancellables)
    }

    private func updateConfirmButton() {
        guard viewModel.canSubmit else {
            navigationItem.rightBarButtonItem = nil
            return
        }
        if navigationItem.rightBarButtonItem != nil { return }
        let item = UIBarButtonItem(
            image: UIImage(systemName: "checkmark"),
            style: .prominent,
            target: self,
            action: #selector(confirmTapped)
        )
        // Figma node 1:8646 — trailing toolbar button uses Primary / Clay Rose
        // (#907064) as the prominent fill; the system colors the SF Symbol
        // white automatically for contrast.
        item.tintColor = UIColor(Color.App.brown2)
        navigationItem.rightBarButtonItem = item
    }

    @objc private func confirmTapped() {
        viewModel.didTapConfirm()
    }
}
