import UIKit

// MARK: - BookingDetailsController (placeholder)

final class BookingDetailsController: BaseHostingViewController<BookingDetailsViewModel, BookingDetailsView> {

    init(viewModel: BookingDetailsViewModel) {
        let view = BookingDetailsView(bookingId: viewModel.bookingId)
        super.init(viewModel: viewModel, rootView: view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Reveal the navigation bar so the system back button is shown.
    override var prefersNavigationBarHidden: Bool { false }
}
