import UIKit

// MARK: - SalonBookingCoordinator
//
// Drives the salon booking flow. Today it pushes the salon profile screen
// (browse services / specialists, share, favorite). Future booking steps
// (service selection, slot picking, confirmation) will be added here so the
// whole flow stays owned by one coordinator.

@MainActor
final class SalonBookingCoordinator: BaseCoordinator {

    private let router: Router
    private let factory: SalonBookingControllerFactory
    private let salonId: String

    var onRequireAuth: (() -> Void)?

    init(parentAssembler: Assembler, router: Router, salonId: String) {
        let assembler = Assembler([SalonBookingAssembly()], parent: parentAssembler)
        self.router = router
        self.factory = assembler.salonBooking.controllerFactory
        self.salonId = salonId
    }

    override func start() {
        showSalonProfile()
    }

    // MARK: - Private

    private func showSalonProfile() {
        let transition = SalonProfileViewModel.Transition(
            didTapBack: { [weak self] in
                self?.router.pop()
                self?.onFinish?()
            },
            didRequireAuth: { [weak self] in
                self?.onRequireAuth?()
            },
            didRequestBooking: { [weak self] salon, entry, availableServiceIds in
                self?.showSelectService(salon: salon, entry: entry, availableServiceIds: availableServiceIds)
            },
            didCompleteEasyweekBooking: { [weak self] booking in
                self?.showEasyweekBookingSuccess(booking: booking)
            }
        )
        let vc = factory.makeSalonProfile(salonId: salonId, transition: transition)
        router.push(vc, animated: true)
    }

    // EasyWeek booking is made in the web widget and confirmed on the backend;
    // show the same success splash → details handoff as the in-app Altegio flow.
    private func showEasyweekBookingSuccess(booking: Booking) {
        let transition = BookingSuccessViewModel.Transition(
            didFinish: { [weak self] in
                guard let self else { return }
                // Collapse back to the salon profile, then push the details screen
                // so back from details returns to the salon profile.
                self.router.popTo(SalonProfileController.self, animated: false)
                self.showBookingDetails(booking: booking)
            }
        )
        let vc = factory.makeBookingSuccess(transition: transition)
        router.push(vc, animated: true)
    }

    private func showSelectService(salon: Salon, entry: SalonBookingEntry, availableServiceIds: Set<String>) {
        // Back navigation is handled by the system back button on the pushed
        // controller; the transition only forwards to the date/time step.
        let transition = SelectServiceViewModel.Transition(
            didContinue: { [weak self] salon, serviceIds, workerId, datetime in
                self?.showSelectDateTime(
                    salon: salon,
                    selectedServiceIds: serviceIds,
                    workerId: workerId,
                    datetime: datetime
                )
            }
        )
        let vc = factory.makeSelectService(
            salon: salon,
            entry: entry,
            availableServiceIds: availableServiceIds,
            transition: transition
        )
        router.push(vc, animated: true)
    }

    private func showSelectDateTime(salon: Salon, selectedServiceIds: Set<String>, workerId: String?, datetime: String?) {
        let transition = SelectDateTimeViewModel.Transition(
            didContinue: { [weak self] salon, serviceIds, workerId, datetime in
                self?.showConfirmBooking(
                    salon: salon,
                    selectedServiceIds: serviceIds,
                    workerId: workerId,
                    datetime: datetime
                )
            }
        )
        let vc = factory.makeSelectDateTime(
            salon: salon,
            selectedServiceIds: selectedServiceIds,
            workerId: workerId,
            datetime: datetime,
            transition: transition
        )
        router.push(vc, animated: true)
    }

    private func showConfirmBooking(salon: Salon, selectedServiceIds: Set<String>, workerId: String?, datetime: String) {
        let transition = ConfirmBookingViewModel.Transition(
            didFinishBooking: { [weak self] created in
                // Booking done — show the success splash, which then hands off to
                // the booking details screen.
                self?.showBookingSuccess(
                    salon: salon,
                    selectedServiceIds: selectedServiceIds,
                    datetime: datetime,
                    created: created
                )
            }
        )
        let vc = factory.makeConfirmBooking(
            salon: salon,
            selectedServiceIds: selectedServiceIds,
            workerId: workerId,
            datetime: datetime,
            transition: transition
        )
        router.push(vc, animated: true)
    }

    private func showBookingSuccess(
        salon: Salon,
        selectedServiceIds: Set<String>,
        datetime: String,
        created: CreatedBooking
    ) {
        let transition = BookingSuccessViewModel.Transition(
            didFinish: { [weak self] in
                guard let self else { return }
                let booking = CreatedBookingMapper.make(
                    salon: salon,
                    selectedServiceIds: selectedServiceIds,
                    datetime: datetime,
                    created: created
                )
                // Collapse the booking stack back to the salon profile (removes the
                // confirm + success + selection steps), then push the details
                // screen — so back from details returns to the salon profile.
                self.router.popTo(SalonProfileController.self, animated: false)
                self.showBookingDetails(booking: booking)
            }
        )
        let vc = factory.makeBookingSuccess(transition: transition)
        router.push(vc, animated: true)
    }

    private func showBookingDetails(booking: Booking) {
        let transition = BookingDetailsViewModel.Transition(
            didTapBookAgain: { [weak self] _ in
                // Future bookings don't surface "book again"; if ever reached,
                // return to the salon profile already in the stack.
                self?.router.popTo(SalonProfileController.self, animated: true)
            },
            didRequireAuth: { [weak self] in
                self?.onRequireAuth?()
            }
        )
        let vc = factory.makeBookingDetails(booking: booking, transition: transition)
        router.push(vc, animated: true)
    }
}
