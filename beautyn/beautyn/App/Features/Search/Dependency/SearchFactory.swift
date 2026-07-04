import Foundation

// MARK: - Protocol

protocol SearchFactory: ResolverInjector {
    var searchRepository: any SearchRepository { get }
    var searchSalonsUseCase: any SearchSalonsUseCase { get }
    var searchPinsUseCase: any SearchPinsUseCase { get }
    var resolveInitialSearchRegionUseCase: any ResolveInitialSearchRegionUseCase { get }
    var getUserLocationUseCase: any GetUserLocationUseCase { get }
    var observeLocationPermissionUseCase: any ObserveLocationPermissionUseCase { get }
    var controllerFactory: any SearchControllerFactory { get }
}

// MARK: - Default implementations

extension SearchFactory {
    var searchRepository: any SearchRepository { resolver.require((any SearchRepository).self) }
    var searchSalonsUseCase: any SearchSalonsUseCase { resolver.require((any SearchSalonsUseCase).self) }
    var searchPinsUseCase: any SearchPinsUseCase { resolver.require((any SearchPinsUseCase).self) }
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
