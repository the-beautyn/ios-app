import UIKit

// MARK: - MyBookingsCoordinator
//
// Roots the Bookings tab. Pushes a (placeholder) booking-details screen when a
// booking is tapped, and reuses `SalonBookingCoordinator` to open the salon
// profile when "Забронювати" is tapped on a past/cancelled booking.

@MainActor
final class MyBookingsCoordinator: BaseCoordinator {

    private let router: Router
    private let factory: MyBookingsControllerFactory
    private let parentAssembler: Assembler

    var onRequireAuth: (() -> Void)?

    init(router: Router, parentAssembler: Assembler) {
        // SalonBookingAssembly is included so the booking-details screen can reach
        // the salon-by-id / salon-share use cases (for the favorite + share
        // controls); "book again" still spins up its own child coordinator.
        let assembler = Assembler([MyBookingsAssembly(), SalonBookingAssembly()], parent: parentAssembler)
        self.router = router
        self.factory = assembler.myBookings.controllerFactory
        self.parentAssembler = parentAssembler
    }

    override func start() {
        showMyBookings()
    }

    // MARK: - Private

    private func showMyBookings() {
        let transition = MyBookingsViewModel.Transition(
            didTapBookingDetails: { [weak self] booking in
                self?.showBookingDetails(booking: booking)
            },
            didTapBook: { [weak self] salonId in
                self?.showSalonProfile(salonId: salonId)
            }
        )
        let vc = factory.makeMyBookings(transition: transition)
        router.setRoot(vc, animated: false)
    }

    private func showBookingDetails(booking: Booking) {
        let transition = BookingDetailsViewModel.Transition(
            didTapBookAgain: { [weak self] salonId in
                self?.showSalonProfile(salonId: salonId)
            },
            didRequireAuth: { [weak self] in
                self?.onRequireAuth?()
            }
        )
        let vc = factory.makeBookingDetails(booking: booking, transition: transition)
        router.push(vc, animated: true)
    }

    private func showSalonProfile(salonId: String) {
        let coordinator = SalonBookingCoordinator(
            parentAssembler: parentAssembler,
            router: router,
            salonId: salonId
        )
        coordinator.onRequireAuth = { [weak self] in self?.onRequireAuth?() }
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.removeChild(coordinator)
        }
        addChild(coordinator)
        coordinator.start()
    }
}
