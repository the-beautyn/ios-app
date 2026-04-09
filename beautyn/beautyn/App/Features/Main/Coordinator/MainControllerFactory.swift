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
        let useCase: any GetHomeFeedUseCase = assembler.require((any GetHomeFeedUseCase).self)
        let sessionManager: SessionManager = assembler.require(SessionManager.self)
        let userRepository: any UserRepository = assembler.require((any UserRepository).self)
        let viewModel = HomeViewModel(transition: transition, getHomeFeedUseCase: useCase, sessionManager: sessionManager, userRepository: userRepository)
        return HomeController(viewModel: viewModel)
    }
}
