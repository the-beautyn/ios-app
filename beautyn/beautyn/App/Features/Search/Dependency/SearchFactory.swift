import Foundation

// MARK: - Protocol

protocol SearchFactory: ResolverInjector {
    var searchRepository: any SearchRepository { get }
    var searchSalonsUseCase: any SearchSalonsUseCase { get }
    var searchPinsUseCase: any SearchPinsUseCase { get }
    var getSearchHistoryUseCase: any GetSearchHistoryUseCase { get }
    var clearSearchHistoryUseCase: any ClearSearchHistoryUseCase { get }
    var deleteSearchHistoryItemUseCase: any DeleteSearchHistoryItemUseCase { get }
    var resolveInitialSearchRegionUseCase: any ResolveInitialSearchRegionUseCase { get }
    var getUserLocationUseCase: any GetUserLocationUseCase { get }
    var observeLocationPermissionUseCase: any ObserveLocationPermissionUseCase { get }
    var getLocationCompletionsUseCase: any GetLocationCompletionsUseCase { get }
    var resolveLocationCompletionUseCase: any ResolveLocationCompletionUseCase { get }
    var reverseGeocodeNameUseCase: any ReverseGeocodeNameUseCase { get }
    var controllerFactory: any SearchControllerFactory { get }
}

// MARK: - Default implementations

extension SearchFactory {
    var searchRepository: any SearchRepository { resolver.require((any SearchRepository).self) }
    var searchSalonsUseCase: any SearchSalonsUseCase { resolver.require((any SearchSalonsUseCase).self) }
    var searchPinsUseCase: any SearchPinsUseCase { resolver.require((any SearchPinsUseCase).self) }
    var getSearchHistoryUseCase: any GetSearchHistoryUseCase {
        resolver.require((any GetSearchHistoryUseCase).self)
    }
    var clearSearchHistoryUseCase: any ClearSearchHistoryUseCase {
        resolver.require((any ClearSearchHistoryUseCase).self)
    }
    var deleteSearchHistoryItemUseCase: any DeleteSearchHistoryItemUseCase {
        resolver.require((any DeleteSearchHistoryItemUseCase).self)
    }
    var getLocationCompletionsUseCase: any GetLocationCompletionsUseCase {
        resolver.require((any GetLocationCompletionsUseCase).self)
    }
    var resolveLocationCompletionUseCase: any ResolveLocationCompletionUseCase {
        resolver.require((any ResolveLocationCompletionUseCase).self)
    }
    var reverseGeocodeNameUseCase: any ReverseGeocodeNameUseCase {
        resolver.require((any ReverseGeocodeNameUseCase).self)
    }
    var resolveInitialSearchRegionUseCase: any ResolveInitialSearchRegionUseCase {
        resolver.require((any ResolveInitialSearchRegionUseCase).self)
    }
    var getUserLocationUseCase: any GetUserLocationUseCase {
        resolver.require((any GetUserLocationUseCase).self)
    }
    var observeLocationPermissionUseCase: any ObserveLocationPermissionUseCase {
        resolver.require((any ObserveLocationPermissionUseCase).self)
    }
    var controllerFactory: any SearchControllerFactory { resolver.require((any SearchControllerFactory).self) }
}

// MARK: - Implementation

final class SearchFactoryImpl: ResolverInjectorImpl, SearchFactory {}
