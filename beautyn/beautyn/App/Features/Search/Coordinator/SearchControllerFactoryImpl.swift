import UIKit

// MARK: - SearchControllerFactoryImpl

@MainActor
final class SearchControllerFactoryImpl: SearchControllerFactory {

    private let assembler: AssemblerLike

    init(assembler: AssemblerLike) {
        self.assembler = assembler
    }

    func makeSearch(transition: SearchViewModel.Transition) -> UIViewController {
        let viewModel = SearchViewModel(
            transition: transition,
            searchSalonsUseCase: assembler.search.searchSalonsUseCase,
            searchPinsUseCase: assembler.search.searchPinsUseCase,
            resolveInitialRegionUseCase: assembler.search.resolveInitialSearchRegionUseCase,
            getUserLocationUseCase: assembler.search.getUserLocationUseCase,
            observeLocationPermissionUseCase: assembler.search.observeLocationPermissionUseCase,
            saveSalonUseCase: assembler.app.saveSalonUseCase,
            unsaveSalonUseCase: assembler.app.unsaveSalonUseCase,
            savedSalonsEventBus: assembler.app.savedSalonsEventBus,
            sessionManager: assembler.app.sessionManager
        )
        return SearchController(viewModel: viewModel)
    }
}
