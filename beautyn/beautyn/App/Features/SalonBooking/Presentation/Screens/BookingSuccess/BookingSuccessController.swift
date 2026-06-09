import SwiftUI
import UIKit

// MARK: - BookingSuccessController

final class BookingSuccessController: BaseHostingViewController<BookingSuccessViewModel, BookingSuccessView> {

    init(viewModel: BookingSuccessViewModel) {
        let view = BookingSuccessView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Full-bleed splash: keep the navigation bar hidden (the default) and block the
    // back swipe so this transient screen can't be dismissed before its timer fires.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}
