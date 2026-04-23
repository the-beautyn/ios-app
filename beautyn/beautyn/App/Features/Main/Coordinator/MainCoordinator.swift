import UIKit

// MARK: - MainCoordinator

@MainActor
final class MainCoordinator: BaseCoordinator {

    private let router: Router
    private let factory: MainControllerFactory

    var onRequireAuth: (() -> Void)?

    init(router: Router, parentAssembler: Assembler) {
        let assembler = Assembler([MainAssembly()], parent: parentAssembler)
        self.factory = assembler.main.controllerFactory
        self.router = router
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
                self?.navigateToSalonProfile(salonId: salonId)
            },
            didTapSavedSalon: { [weak self] salonId in
                self?.navigateToSalonProfile(salonId: salonId)
            },
            didTapSeeAllSaved: { [weak self] in
                self?.navigateToSavedSalons()
            },
            didTapSeeAllSection: { [weak self] sectionId in
                self?.navigateToSectionAll(sectionId: sectionId)
            },
            didTapAppointmentDetails: { [weak self] bookingId in
                self?.navigateToBookingDetails(bookingId: bookingId)
            },
            didTapCategory: { [weak self] categoryId in
                self?.navigateToCategory(categoryId: categoryId)
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
        // TODO: Switch to Search tab or push Search screen
    }

    private func navigateToSalonProfile(salonId: String) {
        // TODO: Push SalonProfile screen
    }

    private func navigateToSavedSalons() {
        // TODO: Push SavedSalons list
    }

    private func navigateToSectionAll(sectionId: String) {
        // TODO: Push section detail / search with filter
    }

    private func navigateToBookingDetails(bookingId: String) {
        // TODO: Push BookingDetails screen
    }

    private func navigateToCategory(categoryId: String) {
        // TODO: Push search filtered by category
    }
}
