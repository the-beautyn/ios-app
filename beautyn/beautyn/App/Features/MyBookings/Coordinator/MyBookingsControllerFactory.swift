import UIKit

// MARK: - MyBookingsControllerFactory

@MainActor
protocol MyBookingsControllerFactory {
    func makeMyBookings(transition: MyBookingsViewModel.Transition) -> UIViewController
    func makeBookingDetails(bookingId: String) -> UIViewController
}

// MARK: - MyBookingsControllerFactoryImpl

@MainActor
final class MyBookingsControllerFactoryImpl: MyBookingsControllerFactory {

    private let assembler: AssemblerLike

    init(assembler: AssemblerLike) {
        self.assembler = assembler
    }

    func makeMyBookings(transition: MyBookingsViewModel.Transition) -> UIViewController {
        let viewModel = MyBookingsViewModel(
            transition: transition,
            getMyBookingsUseCase: assembler.myBookings.getMyBookingsUseCase,
            bookingEventBus: assembler.require((any BookingEventBus).self)
        )
        return MyBookingsController(viewModel: viewModel)
    }

    func makeBookingDetails(bookingId: String) -> UIViewController {
        BookingDetailsController(viewModel: BookingDetailsViewModel(bookingId: bookingId))
    }
}
