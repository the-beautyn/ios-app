import Foundation

// MARK: - HomeAssembly

final class HomeAssembly: Assembly {
    func assemble(container: Container) {
        container.register((any HomeFeedRepository).self) { resolver in
            HomeFeedRepositoryImpl(
                networkService: resolver.require((any NetworkService).self)
            )
        }

        container.register((any GetHomeFeedUseCase).self) { resolver in
            GetHomeFeedUseCaseImpl(
                repository: resolver.require((any HomeFeedRepository).self)
            )
        }

        container.register((any HomeControllerFactory).self) { resolver in
            HomeControllerFactoryImpl(assembler: resolver)
        }

        container.register((any HomeFactory).self) { resolver in
            HomeFactoryImpl(resolver: resolver)
        }
    }
}
