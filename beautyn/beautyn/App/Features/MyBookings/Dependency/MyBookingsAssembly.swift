import Foundation

// MARK: - MyBookingsAssembly

final class MyBookingsAssembly: Assembly {
    func assemble(container: Container) {
        container.register((any MyBookingsRepository).self) { resolver in
            MyBookingsRepositoryImpl(
                networkService: resolver.require((any NetworkService).self)
            )
        }

        container.register((any GetMyBookingsUseCase).self) { resolver in
            GetMyBookingsUseCaseImpl(
                repository: resolver.require((any MyBookingsRepository).self)
            )
        }

        container.register((any MyBookingsControllerFactory).self) { resolver in
            MyBookingsControllerFactoryImpl(assembler: resolver)
        }

        container.register((any MyBookingsFactory).self) { resolver in
            MyBookingsFactoryImpl(resolver: resolver)
        }
    }
}
