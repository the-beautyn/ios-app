import UIKit

// MARK: - MainControllerFactory

@MainActor
protocol MainControllerFactory {
    func makeHome(transition: HomeViewModel.Transition) -> UIViewController
}

// MARK: - MainControllerFactoryImpl

@MainActor
final class MainControllerFactoryImpl: MainControllerFactory {

    private let assembler: AssemblerLike

    init(assembler: AssemblerLike) {
        self.assembler = assembler
    }

    func makeHome(transition: HomeViewModel.Transition) -> UIViewController {
        let viewModel = HomeViewModel(
            transition: transition,
            getHomeFeedUseCase: assembler.main.getHomeFeedUseCase,
            sessionManager: assembler.app.sessionManager,
            userRepository: assembler.app.userRepository
        )
        return HomeController(viewModel: viewModel)
    }
}
