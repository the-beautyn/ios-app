import UIKit

// MARK: - HomeCoordinator

@MainActor
final class HomeCoordinator: BaseCoordinator {

    private let router: Router
    private let factory: HomeControllerFactory
    private let parentAssembler: Assembler

    var onRequireAuth: (() -> Void)?
    var onNavigateToSearchTab: (() -> Void)?
    /// Switches to the Search tab and re-searches with this category applied.
    var onSearchCategory: ((AppCategory) -> Void)?

    init(router: Router, parentAssembler: Assembler) {
        // SalonBookingAssembly is included so the booking-details screen can reach
        // the salon-by-id / salon-share use cases (for the favorite + share
        // controls); "book again" still spins up its own child coordinator.
        let assembler = Assembler([HomeAssembly(), SalonBookingAssembly()], parent: parentAssembler)
        self.factory = assembler.home.controllerFactory
        self.router = router
        self.parentAssembler = parentAssembler
    }

    override func start() {
        showHome()
    }

    // MARK: - Private

    private func showHome() {
        let transition = HomeViewModel.Transition(
            didTapSearch: { [weak self] in
                self?.navigateToSearch()
            },
            didTapSalonCard: { [weak self] salonId in
                self?.navigateToSalonBooking(salonId: salonId)
            },
            didTapSavedSalon: { [weak self] salonId in
                self?.navigateToSalonBooking(salonId: salonId)
            },
            didTapSeeAllSaved: { [weak self] in
                self?.navigateToSavedSalons()
            },
            didTapSeeAllSection: { [weak self] sectionId in
                self?.navigateToSectionAll(sectionId: sectionId)
            },
            didTapAppointmentDetails: { [weak self] booking in
                self?.navigateToBookingDetails(booking: booking)
            },
            didTapCategory: { [weak self] category in
                self?.onSearchCategory?(category)
            },
            didRequireAuth: { [weak self] in
                self?.onRequireAuth?()
            }
        )

        let vc = factory.makeHome(transition: transition)
        router.setRoot(vc, animated: false)
    }

    // MARK: - Navigation Stubs

    private func navigateToSearch() {
        onNavigateToSearchTab?()
    }

    func navigateToSalonBooking(salonId: String) {
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

    private func navigateToSavedSalons() {
        // TODO: Push SavedSalons list
    }

    private func navigateToSectionAll(sectionId: String) {
        // TODO: Push section detail / search with filter
    }

    private func navigateToBookingDetails(booking: Booking) {
        router.push(makeBookingDetails(booking: booking), animated: true)
    }

    private func makeBookingDetails(booking: Booking) -> UIViewController {
        let transition = BookingDetailsViewModel.Transition(
            didTapBookAgain: { [weak self] salonId in
                self?.navigateToSalonBooking(salonId: salonId)
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
