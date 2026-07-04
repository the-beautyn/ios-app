import UIKit

// MARK: - HomeControllerFactory

@MainActor
protocol HomeControllerFactory {
    func makeHome(transition: HomeViewModel.Transition) -> UIViewController
    func makeBookingDetails(
        booking: Booking,
        transition: BookingDetailsViewModel.Transition
    ) -> UIViewController
}
