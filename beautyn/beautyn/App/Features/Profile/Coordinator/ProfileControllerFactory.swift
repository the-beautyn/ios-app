import UIKit

// MARK: - ProfileControllerFactory

@MainActor
protocol ProfileControllerFactory {
    func makeProfile(transition: ProfileViewModel.Transition) -> UIViewController
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
}
