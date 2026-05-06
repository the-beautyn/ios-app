import UIKit

// MARK: - ProfileCoordinator

@MainActor
final class ProfileCoordinator: BaseCoordinator {

    private let router: Router
    private let factory: ProfileControllerFactory
    private let parentAssembler: Assembler

    init(router: Router, parentAssembler: Assembler) {
        let assembler = Assembler([ProfileAssembly()], parent: parentAssembler)
        self.factory = assembler.profile.controllerFactory
        self.router = router
        self.parentAssembler = parentAssembler
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
        let transition = EditProfileViewModel.Transition(
            didFinishEditing: { [weak self] in self?.router.pop(animated: true) },
            didChangePhone: { [weak self] phone in self?.showPhoneVerification(phone: phone) }
        )
        let vc = factory.makeEditProfile(transition: transition)
        router.push(vc, animated: true)
    }

    private func showPhoneVerification(phone: String) {
        let coordinator = PhoneVerificationCoordinator(
            parentAssembler: parentAssembler,
            router: router,
            initialPhone: phone
        )
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.router.popTo(PersonalDataController.self, animated: true)
            self.removeChild(coordinator)
        }
        addChild(coordinator)
        coordinator.start()
    }

    private func handleEditAvatarTap() {
        // TODO: Present avatar source sheet + upload
    }

    private func navigateToSavedSalons() {
        let transition = SavedSalonsViewModel.Transition(
            didTapSalon: { [weak self] salonId in self?.navigateToSalon(salonId: salonId) },
            didTapBack:  { [weak self] in self?.router.pop(animated: true) }
        )
        let vc = factory.makeSavedSalons(transition: transition)
        router.push(vc, animated: true)
    }

    private func navigateToSalon(salonId: String) {
        // TODO: Push Salon Profile screen
    }

    private func navigateToSettings() {
        let transition = ProfileSettingsViewModel.Transition(
            didTapChangePassword: { [weak self] in self?.handleChangePasswordTap() },
            didLogout: { [weak self] in self?.handleLogoutCompleted() },
            didDeleteAccount: { [weak self] in self?.handleDeleteAccountCompleted() }
        )
        let vc = factory.makeProfileSettings(transition: transition)
        router.push(vc, animated: true)
    }

    private func handleChangePasswordTap() {
        let transition = ChangePasswordViewModel.Transition(
            didFinishChanging: { [weak self] in self?.router.pop(animated: true) }
        )
        router.push(factory.makeChangePassword(transition: transition), animated: true)
    }

    private func handleLogoutCompleted() {
        router.popToRoot(animated: true)
    }

    private func handleDeleteAccountCompleted() {
        router.popToRoot(animated: true)
    }

    private func navigateToLanguage() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
