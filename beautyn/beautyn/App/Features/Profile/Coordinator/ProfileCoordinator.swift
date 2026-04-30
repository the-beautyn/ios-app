import UIKit

// MARK: - ProfileCoordinator

@MainActor
final class ProfileCoordinator: BaseCoordinator {

    private let router: Router
    private let factory: ProfileControllerFactory

    init(router: Router, parentAssembler: Assembler) {
        let assembler = Assembler([ProfileAssembly()], parent: parentAssembler)
        self.factory = assembler.profile.controllerFactory
        self.router = router
    }

    override func start() {
        showProfile()
    }

    // MARK: - Private

    private func showProfile() {
        let transition = ProfileViewModel.Transition(
            didTapPersonalData: { [weak self] in
                self?.navigateToPersonalData()
            },
            didTapSavedSalons: { [weak self] in
                self?.navigateToSavedSalons()
            },
            didTapSettings: { [weak self] in
                self?.navigateToSettings()
            },
            didTapLanguage: { [weak self] in
                self?.navigateToLanguage()
            }
        )

        let vc = factory.makeProfile(transition: transition)
        router.setRoot(vc, animated: false)
    }

    // MARK: - Navigation Stubs

    private func navigateToPersonalData() {
        let transition = PersonalDataViewModel.Transition(
            didTapEditProfile: { [weak self] in self?.handleEditProfileTap() },
            didTapEditAvatar: { [weak self] in self?.handleEditAvatarTap() }
        )
        let vc = factory.makePersonalData(transition: transition)
        router.push(vc, animated: true)
    }

    private func handleEditProfileTap() {
        // TODO: Push Edit Profile screen
    }

    private func handleEditAvatarTap() {
        // TODO: Present avatar source sheet + upload
    }

    private func navigateToSavedSalons() {
        // TODO: Push Saved Salons screen
    }

    private func navigateToSettings() {
        // TODO: Push Settings screen
    }

    private func navigateToLanguage() {
        // TODO: Push Language screen
    }
}
