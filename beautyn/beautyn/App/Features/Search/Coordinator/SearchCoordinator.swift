import UIKit

// MARK: - SearchCoordinator

@MainActor
final class SearchCoordinator: BaseCoordinator {

    private let router: Router
    private let factory: SearchControllerFactory
    private let parentAssembler: Assembler

    /// Router of the modally presented search sheet (its own nav stack:
    /// text search → Локація). Non-nil only while the sheet is up.
    private var modalRouter: Router?
    private var modalDismissDelegate: SearchModalDismissDelegate?
    /// The tab's root screen — kept so external entry points (Home's search
    /// bar) can open the search sheet with the map's current applied state.
    private weak var searchMapController: SearchMapController?

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
        let transition = SearchMapViewModel.Transition(
            didTapSalonCard: { [weak self] salonId in
                self?.navigateToSalonBooking(salonId: salonId)
            },
            didRequireAuth: { [weak self] in
                self?.onRequireAuth?()
            },
            didTapOpenSettings: {
                Self.openSystemSettings()
            },
            didTapSearchField: { [weak self] context in
                self?.showSearchSheet(context)
            }
        )

        let vc = factory.makeSearchMap(transition: transition)
        searchMapController = vc as? SearchMapController
        router.setRoot(vc, animated: false)
    }

    /// Opens the text-search sheet as if the map's search pill was tapped —
    /// used by Home's search bar after switching to this tab.
    func openSearchSheet() {
        guard modalRouter == nil else { return }
        searchMapController?.viewModel.didTapSearchField()
    }

    // MARK: - Search sheet (modal)

    private func showSearchSheet(_ context: SearchInputContext) {
        let nav = UINavigationController()
        nav.delegate = NavigationBarVisibilityController.shared
        let modalRouter = Router(navigationController: nav)
        self.modalRouter = modalRouter

        let transition = SearchViewModel.Transition(
            didTapClose: { [weak self] in
                self?.dismissSearchSheet()
            },
            didTapLocationField: { [weak self] onSelect in
                self?.showSearchLocation(onSelect: onSelect)
            },
            didSelectSalon: { [weak self] salonId, submission in
                guard let self else { return }
                // Apply the sheet's state first so backing out of the salon
                // profile lands on the search the user just made.
                context.onApply(submission)
                self.modalRouter = nil
                self.router.dismiss { [weak self] in
                    self?.navigateToSalonBooking(salonId: salonId, isFromSearch: true)
                }
            },
            didSubmit: { [weak self] submission in
                // Apply first — the map is already updating behind the
                // dismissing sheet.
                context.onApply(submission)
                self?.dismissSearchSheet()
            }
        )

        modalRouter.setRoot(factory.makeSearch(context: context, transition: transition), animated: false)
        nav.modalPresentationStyle = .pageSheet

        // Swipe-down = cancel: nothing is applied, only the handle is released.
        let delegate = SearchModalDismissDelegate { [weak self] in
            self?.modalRouter = nil
        }
        nav.presentationController?.delegate = delegate
        modalDismissDelegate = delegate

        router.present(nav)
    }

    private func showSearchLocation(onSelect: @escaping (SearchLocation) -> Void) {
        let transition = SearchLocationViewModel.Transition(
            didTapBack: { [weak self] in
                self?.modalRouter?.pop()
            },
            didSelectLocation: { [weak self] location in
                onSelect(location)
                self?.modalRouter?.pop()
            },
            didTapOpenSettings: {
                Self.openSystemSettings()
            }
        )
        modalRouter?.push(factory.makeSearchLocation(transition: transition))
    }

    private func dismissSearchSheet() {
        modalRouter = nil
        router.dismiss()
    }

    private static func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func navigateToSalonBooking(salonId: String, isFromSearch: Bool = false) {
        let coordinator = SalonBookingCoordinator(
            parentAssembler: parentAssembler,
            router: router,
            salonId: salonId,
            isFromSearch: isFromSearch
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

// MARK: - Dismiss Delegate

@MainActor
private final class SearchModalDismissDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
    private let onDismiss: () -> Void

    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onDismiss()
    }
}
