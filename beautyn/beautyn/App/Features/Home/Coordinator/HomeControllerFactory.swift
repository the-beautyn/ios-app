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

// MARK: - HomeControllerFactoryImpl

@MainActor
final class HomeControllerFactoryImpl: HomeControllerFactory {

    private let assembler: AssemblerLike

    init(assembler: AssemblerLike) {
        self.assembler = assembler
    }

    func makeHome(transition: HomeViewModel.Transition) -> UIViewController {
        let viewModel = HomeViewModel(
            transition: transition,
            getHomeFeedUseCase: assembler.home.getHomeFeedUseCase,
            saveSalonUseCase: assembler.app.saveSalonUseCase,
            unsaveSalonUseCase: assembler.app.unsaveSalonUseCase,
            savedSalonsEventBus: assembler.app.savedSalonsEventBus,
            observeBookingUseCase: assembler.app.observeBookingUseCase,
            sessionManager: assembler.app.sessionManager,
            getCurrentUserUseCase: assembler.app.getCurrentUserUseCase
        )
        return HomeController(viewModel: viewModel)
    }

    func makeBookingDetails(
        booking: Booking,
        transition: BookingDetailsViewModel.Transition
    ) -> UIViewController {
        let viewModel = BookingDetailsViewModel(
            booking: booking,
            transition: transition,
            observeBookingUseCase: assembler.app.observeBookingUseCase,
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
