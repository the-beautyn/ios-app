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
        entry: SalonBookingEntry,
        availableServiceIds: Set<String>,
        transition: SelectServiceViewModel.Transition
    ) -> UIViewController

    func makeSelectDateTime(
        salon: Salon,
        selectedServiceIds: Set<String>,
        workerId: String?,
        datetime: String?
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
            getAltegioAvailableServicesUseCase: assembler.salonBooking.getAltegioAvailableServicesUseCase,
            getAltegioAvailableWorkersUseCase: assembler.salonBooking.getAltegioAvailableWorkersUseCase,
            saveSalonUseCase: assembler.require((any SaveSalonUseCase).self),
            unsaveSalonUseCase: assembler.require((any UnsaveSalonUseCase).self),
            savedSalonsEventBus: assembler.require((any SavedSalonsEventBus).self),
            sessionManager: assembler.app.sessionManager
        )
        return SalonProfileController(viewModel: viewModel)
    }

    func makeSelectService(
        salon: Salon,
        entry: SalonBookingEntry,
        availableServiceIds: Set<String>,
        transition: SelectServiceViewModel.Transition
    ) -> UIViewController {
        let viewModel = SelectServiceViewModel(
            salon: salon,
            entry: entry,
            initialAvailableServiceIds: availableServiceIds,
            transition: transition,
            getAltegioAvailableServicesUseCase: assembler.salonBooking.getAltegioAvailableServicesUseCase
        )
        return SelectServiceController(viewModel: viewModel)
    }

    func makeSelectDateTime(
        salon: Salon,
        selectedServiceIds: Set<String>,
        workerId: String?,
        datetime: String?
    ) -> UIViewController {
        let viewModel = SelectDateTimeViewModel(
            salon: salon,
            selectedServiceIds: selectedServiceIds,
            workerId: workerId,
            datetime: datetime,
            getAltegioAvailableWorkersUseCase: assembler.salonBooking.getAltegioAvailableWorkersUseCase,
            getAltegioBookingDatesUseCase: assembler.salonBooking.getAltegioBookingDatesUseCase,
            getAltegioTimeSlotsUseCase: assembler.salonBooking.getAltegioTimeSlotsUseCase
        )
        return SelectDateTimeController(viewModel: viewModel)
    }
}
