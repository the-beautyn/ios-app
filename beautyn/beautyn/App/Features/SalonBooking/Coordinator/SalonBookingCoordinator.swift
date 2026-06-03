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
        let vc = factory.makeSelectDateTime(
            salon: salon,
            selectedServiceIds: selectedServiceIds,
            workerId: workerId,
            datetime: datetime
        )
        router.push(vc, animated: true)
    }
}
