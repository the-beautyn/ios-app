import Foundation

// MARK: - MainAssembly

final class MainAssembly: Assembly {
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

        container.register((any MainControllerFactory).self) { resolver in
            MainControllerFactoryImpl(assembler: resolver)
        }

        container.register((any MainFactory).self) { resolver in
            MainFactoryImpl(resolver: resolver)
        }
    }
}
