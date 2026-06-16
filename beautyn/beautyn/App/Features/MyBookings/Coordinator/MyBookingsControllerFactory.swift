import UIKit

// MARK: - MyBookingsControllerFactory

@MainActor
protocol MyBookingsControllerFactory {
    func makeMyBookings(transition: MyBookingsViewModel.Transition) -> UIViewController
    func makeBookingDetails(
        booking: Booking,
        transition: BookingDetailsViewModel.Transition
    ) -> UIViewController
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
            bookingEventBus: assembler.app.bookingEventBus
        )
        return MyBookingsController(viewModel: viewModel)
    }

    func makeBookingDetails(
        booking: Booking,
        transition: BookingDetailsViewModel.Transition
    ) -> UIViewController {
        let viewModel = BookingDetailsViewModel(
            booking: booking,
            transition: transition,
            getSalonByIdUseCase: assembler.salonBooking.getSalonByIdUseCase,
            getSalonShareUseCase: assembler.salonBooking.getSalonShareUseCase,
            saveSalonUseCase: assembler.app.saveSalonUseCase,
            unsaveSalonUseCase: assembler.app.unsaveSalonUseCase,
            savedSalonsEventBus: assembler.app.savedSalonsEventBus,
            sessionManager: assembler.app.sessionManager
        )
        return BookingDetailsController(viewModel: viewModel)
    }
}
