import UIKit

// MARK: - ProfileControllerFactory

@MainActor
protocol ProfileControllerFactory {
    func makeProfile(transition: ProfileViewModel.Transition) -> UIViewController
    func makePersonalData(transition: PersonalDataViewModel.Transition) -> UIViewController
    func makeEditProfile(transition: EditProfileViewModel.Transition) -> UIViewController
    func makeSavedSalons(transition: SavedSalonsViewModel.Transition) -> UIViewController
}

// MARK: - ProfileControllerFactoryImpl

@MainActor
final class ProfileControllerFactoryImpl: ProfileControllerFactory {

    private let assembler: AssemblerLike

    init(assembler: AssemblerLike) {
        self.assembler = assembler
    }

    func makeProfile(transition: ProfileViewModel.Transition) -> UIViewController {
        let viewModel = ProfileViewModel(
            transition: transition,
            getCurrentUserUseCase: assembler.app.getCurrentUserUseCase,
            getUserSettingsUseCase: assembler.app.getUserSettingsUseCase,
            updateNotificationSettingsUseCase: assembler.app.updateNotificationSettingsUseCase
        )
        return ProfileController(viewModel: viewModel)
    }

    func makePersonalData(transition: PersonalDataViewModel.Transition) -> UIViewController {
        let viewModel = PersonalDataViewModel(
            transition: transition,
            getCurrentUserUseCase: assembler.app.getCurrentUserUseCase
        )
        return PersonalDataController(viewModel: viewModel)
    }

    func makeEditProfile(transition: EditProfileViewModel.Transition) -> UIViewController {
        let viewModel = EditProfileViewModel(
            transition: transition,
            getCurrentUserUseCase: assembler.app.getCurrentUserUseCase,
            updateUserProfileUseCase: assembler.app.updateUserProfileUseCase
        )
        return EditProfileController(viewModel: viewModel)
    }

    func makeSavedSalons(transition: SavedSalonsViewModel.Transition) -> UIViewController {
        let viewModel = SavedSalonsViewModel(
            transition: transition,
            getSavedSalonsUseCase: assembler.require((any GetSavedSalonsUseCase).self),
            saveSalonUseCase: assembler.require((any SaveSalonUseCase).self),
            unsaveSalonUseCase: assembler.require((any UnsaveSalonUseCase).self),
            savedSalonsEventBus: assembler.require((any SavedSalonsEventBus).self)
        )
        return SavedSalonsController(viewModel: viewModel)
    }
}
