import UIKit

// MARK: - SalonBookingControllerFactory

@MainActor
protocol SalonBookingControllerFactory {
    func makeSalonProfile(
        salonId: String,
        isFromSearch: Bool,
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
        datetime: String?,
        transition: SelectDateTimeViewModel.Transition
    ) -> UIViewController

    func makeConfirmBooking(
        salon: Salon,
        selectedServiceIds: Set<String>,
        workerId: String?,
        datetime: String,
        transition: ConfirmBookingViewModel.Transition
    ) -> UIViewController

    func makeBookingSuccess(
        transition: BookingSuccessViewModel.Transition
    ) -> UIViewController

    func makeBookingDetails(
        booking: Booking,
        transition: BookingDetailsViewModel.Transition
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
        isFromSearch: Bool,
        transition: SalonProfileViewModel.Transition
    ) -> UIViewController {
        let viewModel = SalonProfileViewModel(
            salonId: salonId,
            isFromSearch: isFromSearch,
            transition: transition,
            getSalonByIdUseCase: assembler.salonBooking.getSalonByIdUseCase,
            getSalonShareUseCase: assembler.salonBooking.getSalonShareUseCase,
            getAltegioAvailableServicesUseCase: assembler.salonBooking.getAltegioAvailableServicesUseCase,
            getAltegioAvailableWorkersUseCase: assembler.salonBooking.getAltegioAvailableWorkersUseCase,
            saveSalonUseCase: assembler.app.saveSalonUseCase,
            unsaveSalonUseCase: assembler.app.unsaveSalonUseCase,
            savedSalonsEventBus: assembler.app.savedSalonsEventBus,
            sessionManager: assembler.app.sessionManager,
            getCurrentUserUseCase: assembler.app.getCurrentUserUseCase,
            confirmEasyweekBookingUseCase: assembler.salonBooking.confirmEasyweekBookingUseCase
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
        datetime: String?,
        transition: SelectDateTimeViewModel.Transition
    ) -> UIViewController {
        let viewModel = SelectDateTimeViewModel(
            salon: salon,
            selectedServiceIds: selectedServiceIds,
            workerId: workerId,
            datetime: datetime,
            transition: transition,
            getAltegioAvailableWorkersUseCase: assembler.salonBooking.getAltegioAvailableWorkersUseCase,
            getAltegioBookingDatesUseCase: assembler.salonBooking.getAltegioBookingDatesUseCase,
            getAltegioTimeSlotsUseCase: assembler.salonBooking.getAltegioTimeSlotsUseCase
        )
        return SelectDateTimeController(viewModel: viewModel)
    }

    func makeConfirmBooking(
        salon: Salon,
        selectedServiceIds: Set<String>,
        workerId: String?,
        datetime: String,
        transition: ConfirmBookingViewModel.Transition
    ) -> UIViewController {
        let viewModel = ConfirmBookingViewModel(
            salon: salon,
            selectedServiceIds: selectedServiceIds,
            workerId: workerId,
            datetime: datetime,
            transition: transition,
            createBookingUseCase: assembler.salonBooking.createAltegioBookingUseCase,
            getCurrentUserUseCase: assembler.app.getCurrentUserUseCase
        )
        return ConfirmBookingController(viewModel: viewModel)
    }

    func makeBookingSuccess(
        transition: BookingSuccessViewModel.Transition
    ) -> UIViewController {
        let viewModel = BookingSuccessViewModel(transition: transition)
        return BookingSuccessController(viewModel: viewModel)
    }

    func makeBookingDetails(
        booking: Booking,
        transition: BookingDetailsViewModel.Transition
    ) -> UIViewController {
        let viewModel = BookingDetailsViewModel(
            booking: booking,
            transition: transition,
            observeBookingUseCase: assembler.app.observeBookingUseCase,
            refreshBookingUseCase: assembler.app.refreshBookingUseCase,
            syncBookingFromCrmUseCase: assembler.app.syncBookingFromCrmUseCase,
            confirmEasyweekBookingUseCase: assembler.salonBooking.confirmEasyweekBookingUseCase,
            getCurrentUserUseCase: assembler.app.getCurrentUserUseCase,
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
