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
            didRequestBooking: { [weak self] salon, entry in
                self?.showSelectService(salon: salon, entry: entry)
            }
        )
        let vc = factory.makeSalonProfile(salonId: salonId, transition: transition)
        router.push(vc, animated: true)
    }

    private func showSelectService(salon: Salon, entry: SalonBookingEntry) {
        // Back navigation is handled by the system back button on the pushed
        // controller, so no transition is needed yet.
        let vc = factory.makeSelectService(salon: salon, entry: entry)
        router.push(vc, animated: true)
    }
}
