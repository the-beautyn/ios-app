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
            didRequestBooking: { _ in
                // Future: push booking steps (service / slot selection,
                // confirmation) onto this flow's router.
            }
        )
        let vc = factory.makeSalonProfile(salonId: salonId, transition: transition)
        router.push(vc, animated: true)
    }
}
