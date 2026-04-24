import UIKit

// MARK: - HomeControllerFactory

@MainActor
protocol HomeControllerFactory {
    func makeHome(transition: HomeViewModel.Transition) -> UIViewController
}

// MARK: - HomeControllerFactoryImpl

@MainActor
final class HomeControllerFactoryImpl: HomeControllerFactory {

    private let assembler: AssemblerLike

    init(assembler: AssemblerLike) {
        self.assembler = assembler
    }

    func makeHome(transition: HomeViewModel.Transition) -> UIViewController {
        let viewModel = HomeViewModel(
            transition: transition,
            getHomeFeedUseCase: assembler.home.getHomeFeedUseCase,
            sessionManager: assembler.app.sessionManager,
            getCurrentUserUseCase: assembler.app.getCurrentUserUseCase
        )
        return HomeController(viewModel: viewModel)
    }
}
