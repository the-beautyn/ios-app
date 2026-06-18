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
                self?.showBookingSuccess(booking: booking)
            }
        )
        let vc = factory.makeSalonProfile(salonId: salonId, transition: transition)
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
            didFinishBooking: { [weak self] booking in
                // Booking done — show the success splash, which then hands off to the
                // booking details screen built from the backend booking.
                self?.showBookingSuccess(booking: booking)
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

    // Booking done (in-app Altegio create or EasyWeek widget confirm) — show the
    // success splash, then hand off to the details screen. Both providers navigate
    // off the backend `Booking` (fetched into the source of truth at create/confirm),
    // so the details screen reflects the CRM-sourced data.
    private func showBookingSuccess(booking: Booking) {
        let transition = BookingSuccessViewModel.Transition(
            didFinish: { [weak self] in
                guard let self else { return }
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
        router.push(makeBookingDetails(booking: booking), animated: true)
    }

    private func makeBookingDetails(booking: Booking) -> UIViewController {
        let transition = BookingDetailsViewModel.Transition(
            didTapBookAgain: { [weak self] _ in
                // Future bookings don't surface "book again"; if ever reached,
                // return to the salon profile already in the stack.
                self?.router.popTo(SalonProfileController.self, animated: true)
            },
            didRequireAuth: { [weak self] in
                self?.onRequireAuth?()
            },
            didOpenBookingDetails: { [weak self] newBooking in
                guard let self else { return }
                // EasyWeek reschedule / new booking — replace the current details
                // with the new booking, keeping the back stack.
                self.router.replaceTop(self.makeBookingDetails(booking: newBooking), animated: true)
            }
        )
        return factory.makeBookingDetails(booking: booking, transition: transition)
    }
}
