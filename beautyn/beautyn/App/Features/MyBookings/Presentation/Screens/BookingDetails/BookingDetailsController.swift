import Combine
import SwiftUI
import UIKit

// MARK: - BookingDetailsController

final class BookingDetailsController: BaseHostingViewController<BookingDetailsViewModel, BookingDetailsView> {

    private var favoriteItem: UIBarButtonItem?
    private var favoriteCancellable: AnyCancellable?

    init(viewModel: BookingDetailsViewModel) {
        let view = BookingDetailsView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // The cover photo is full-bleed under a transparent bar; the system back
    // button plus the share / favorite items get Liquid Glass automatically on
    // iOS 26, matching the floating controls in the Figma design.
    override var prefersNavigationBarHidden: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTransparentNavigationBar()
        configureBarButtons()
        observeFavoriteState()
    }

    // MARK: - Navigation bar

    private func configureTransparentNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }

    private func configureBarButtons() {
        let tint = UIColor(Color.App.text)

        let share = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(didTapShare)
        )
        share.tintColor = tint

        let favorite = UIBarButtonItem(
            image: favoriteImage(isFavorited: viewModel.isFavorited),
            style: .plain,
            target: self,
            action: #selector(didTapFavorite)
        )
        favorite.tintColor = tint
        favoriteItem = favorite

        // rightBarButtonItems lay out right-to-left, so favorite (first) is the
        // rightmost and share sits to its left — matching the Figma order.
        navigationItem.rightBarButtonItems = [favorite, share]
    }

    private func observeFavoriteState() {
        favoriteCancellable = viewModel.$isFavorited
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavorited in
                self?.favoriteItem?.image = self?.favoriteImage(isFavorited: isFavorited)
            }
    }

    private func favoriteImage(isFavorited: Bool) -> UIImage? {
        UIImage(systemName: isFavorited ? "heart.fill" : "heart")
    }

    // MARK: - Actions

    @objc private func didTapShare() {
        viewModel.didTapShare()
    }

    @objc private func didTapFavorite() {
        viewModel.didTapFavorite()
    }
}
