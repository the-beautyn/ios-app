import Foundation

// MARK: - SearchAssembly

final class SearchAssembly: Assembly {
    func assemble(container: Container) {
        // One shared instance — the service owns the CLLocationManager and the
        // permission state; every use case must observe the same one.
        let locationService = SearchLocationServiceImpl()
        container.register((any SearchLocationService).self) { _ in locationService }

        container.register((any ResolveInitialSearchRegionUseCase).self) { resolver in
            ResolveInitialSearchRegionUseCaseImpl(
                locationService: resolver.require((any SearchLocationService).self),
                getCurrentUserUseCase: resolver.require((any GetCurrentUserUseCase).self),
                sessionManager: resolver.require(SessionManager.self)
            )
        }

        container.register((any GetUserLocationUseCase).self) { resolver in
            GetUserLocationUseCaseImpl(
                locationService: resolver.require((any SearchLocationService).self)
            )
        }

        container.register((any ObserveLocationPermissionUseCase).self) { resolver in
            ObserveLocationPermissionUseCaseImpl(
                locationService: resolver.require((any SearchLocationService).self)
            )
        }

        container.register((any GetLocationCompletionsUseCase).self) { resolver in
            GetLocationCompletionsUseCaseImpl(
                locationService: resolver.require((any SearchLocationService).self)
            )
        }

        container.register((any ResolveLocationCompletionUseCase).self) { resolver in
            ResolveLocationCompletionUseCaseImpl(
                locationService: resolver.require((any SearchLocationService).self)
            )
        }

        container.register((any ReverseGeocodeNameUseCase).self) { resolver in
            ReverseGeocodeNameUseCaseImpl(
                locationService: resolver.require((any SearchLocationService).self)
            )
        }

        container.register((any SearchRepository).self) { resolver in
            SearchRepositoryImpl(
                networkService: resolver.require((any NetworkService).self)
            )
        }

        container.register((any SearchSalonsUseCase).self) { resolver in
            SearchSalonsUseCaseImpl(
                repository: resolver.require((any SearchRepository).self)
            )
        }

        container.register((any SearchPinsUseCase).self) { resolver in
            SearchPinsUseCaseImpl(
                repository: resolver.require((any SearchRepository).self)
            )
        }

        container.register((any GetSearchFilterOptionsUseCase).self) { resolver in
            GetSearchFilterOptionsUseCaseImpl(
                repository: resolver.require((any SearchRepository).self)
            )
        }

        container.register((any GetAppCategoriesUseCase).self) { resolver in
            GetAppCategoriesUseCaseImpl(
                repository: resolver.require((any SearchRepository).self)
            )
        }

        container.register((any GetSearchHistoryUseCase).self) { resolver in
            GetSearchHistoryUseCaseImpl(
                repository: resolver.require((any SearchRepository).self)
            )
        }

        container.register((any ClearSearchHistoryUseCase).self) { resolver in
            ClearSearchHistoryUseCaseImpl(
                repository: resolver.require((any SearchRepository).self)
            )
        }

        container.register((any DeleteSearchHistoryItemUseCase).self) { resolver in
            DeleteSearchHistoryItemUseCaseImpl(
                repository: resolver.require((any SearchRepository).self)
            )
        }

        container.register((any SearchControllerFactory).self) { resolver in
            SearchControllerFactoryImpl(assembler: resolver)
        }

        container.register((any SearchFactory).self) { resolver in
            SearchFactoryImpl(resolver: resolver)
        }
    }
}
