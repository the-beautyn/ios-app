import UIKit

// MARK: - SearchCoordinator

@MainActor
final class SearchCoordinator: BaseCoordinator {

    private let router: Router
    private let factory: SearchControllerFactory
    private let parentAssembler: Assembler

    var onRequireAuth: (() -> Void)?

    init(router: Router, parentAssembler: Assembler) {
        let assembler = Assembler([SearchAssembly()], parent: parentAssembler)
        self.factory = assembler.search.controllerFactory
        self.router = router
        self.parentAssembler = parentAssembler
    }

    override func start() {
        showSearch()
    }

    // MARK: - Private

    private func showSearch() {
        let transition = SearchViewModel.Transition(
            didTapSalonCard: { [weak self] salonId in
                self?.navigateToSalonBooking(salonId: salonId)
            },
            didRequireAuth: { [weak self] in
                self?.onRequireAuth?()
            },
            didTapOpenSettings: {
                Self.openSystemSettings()
            }
        )

        let vc = factory.makeSearch(transition: transition)
        router.setRoot(vc, animated: false)
    }

    private static func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func navigateToSalonBooking(salonId: String) {
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
