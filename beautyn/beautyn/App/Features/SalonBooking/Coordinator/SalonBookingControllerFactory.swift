import UIKit

// MARK: - SalonBookingControllerFactory

@MainActor
protocol SalonBookingControllerFactory {
    func makeSalonProfile(
        salonId: String,
        transition: SalonProfileViewModel.Transition
    ) -> UIViewController

    func makeSelectService(
        salon: Salon,
        entry: SalonBookingEntry
    ) -> UIViewController
}

// MARK: - SalonBookingControllerFactoryImpl

@MainActor
final class SalonBookingControllerFactoryImpl: SalonBookingControllerFactory {

    private let assembler: AssemblerLike

    init(assembler: AssemblerLike) {
        self.assembler = assembler
    }

    func makeSalonProfile(
        salonId: String,
        transition: SalonProfileViewModel.Transition
    ) -> UIViewController {
        let viewModel = SalonProfileViewModel(
            salonId: salonId,
            transition: transition,
            getSalonByIdUseCase: assembler.salonBooking.getSalonByIdUseCase,
            getSalonShareUseCase: assembler.salonBooking.getSalonShareUseCase,
            saveSalonUseCase: assembler.require((any SaveSalonUseCase).self),
            unsaveSalonUseCase: assembler.require((any UnsaveSalonUseCase).self),
            savedSalonsEventBus: assembler.require((any SavedSalonsEventBus).self),
            sessionManager: assembler.app.sessionManager
        )
        return SalonProfileController(viewModel: viewModel)
    }

    func makeSelectService(
        salon: Salon,
        entry: SalonBookingEntry
    ) -> UIViewController {
        let viewModel = SelectServiceViewModel(salon: salon, entry: entry)
        return SelectServiceController(viewModel: viewModel)
    }
}
