import UIKit

// MARK: - SearchControllerFactoryImpl

@MainActor
final class SearchControllerFactoryImpl: SearchControllerFactory {

    private let assembler: AssemblerLike

    init(assembler: AssemblerLike) {
        self.assembler = assembler
    }

    func makeSearchMap(transition: SearchMapViewModel.Transition) -> UIViewController {
        let viewModel = SearchMapViewModel(
            transition: transition,
            searchSalonsUseCase: assembler.search.searchSalonsUseCase,
            searchPinsUseCase: assembler.search.searchPinsUseCase,
            getSearchFilterOptionsUseCase: assembler.search.getSearchFilterOptionsUseCase,
            resolveInitialRegionUseCase: assembler.search.resolveInitialSearchRegionUseCase,
            getUserLocationUseCase: assembler.search.getUserLocationUseCase,
            observeLocationPermissionUseCase: assembler.search.observeLocationPermissionUseCase,
            saveSalonUseCase: assembler.app.saveSalonUseCase,
            unsaveSalonUseCase: assembler.app.unsaveSalonUseCase,
            savedSalonsEventBus: assembler.app.savedSalonsEventBus,
            sessionManager: assembler.app.sessionManager
        )
        return SearchMapController(viewModel: viewModel)
    }

    func makeSearch(context: SearchInputContext, transition: SearchViewModel.Transition) -> UIViewController {
        let viewModel = SearchViewModel(
            transition: transition,
            initialQuery: context.initialQuery,
            initialLocation: context.initialLocation,
            initialDate: context.initialDate,
            mapCenter: context.mapCenter,
            getSearchHistoryUseCase: assembler.search.getSearchHistoryUseCase,
            clearSearchHistoryUseCase: assembler.search.clearSearchHistoryUseCase,
            deleteSearchHistoryItemUseCase: assembler.search.deleteSearchHistoryItemUseCase,
            searchSalonsUseCase: assembler.search.searchSalonsUseCase,
            sessionManager: assembler.app.sessionManager
        )
        return SearchController(viewModel: viewModel)
    }

    func makeSearchSort(context: SearchSortContext, transition: SearchSortViewModel.Transition) -> UIViewController {
        let viewModel = SearchSortViewModel(transition: transition, context: context)
        return SearchSortController(viewModel: viewModel)
    }

    func makeSearchLocation(transition: SearchLocationViewModel.Transition) -> UIViewController {
        let viewModel = SearchLocationViewModel(
            transition: transition,
            getLocationCompletionsUseCase: assembler.search.getLocationCompletionsUseCase,
            resolveLocationCompletionUseCase: assembler.search.resolveLocationCompletionUseCase,
            getUserLocationUseCase: assembler.search.getUserLocationUseCase,
            reverseGeocodeNameUseCase: assembler.search.reverseGeocodeNameUseCase,
            observeLocationPermissionUseCase: assembler.search.observeLocationPermissionUseCase
        )
        return SearchLocationController(viewModel: viewModel)
    }

    func makeSearchDatePicker(initialDate: Date?, transition: SearchDatePickerViewModel.Transition) -> UIViewController {
        let viewModel = SearchDatePickerViewModel(transition: transition, initialDate: initialDate)
        return SearchDatePickerController(viewModel: viewModel)
    }
}
