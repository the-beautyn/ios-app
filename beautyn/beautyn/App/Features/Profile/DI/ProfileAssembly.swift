import Foundation

// MARK: - ProfileAssembly

final class ProfileAssembly: Assembly {
    func assemble(container: Container) {
        container.register((any ProfileControllerFactory).self) { resolver in
            ProfileControllerFactoryImpl(assembler: resolver)
        }

        container.register((any ProfileFactory).self) { resolver in
            ProfileFactoryImpl(resolver: resolver)
        }

        container.register((any GetSavedSalonsUseCase).self) { resolver in
            GetSavedSalonsUseCaseImpl(
                repository: resolver.require((any SavedSalonsRepository).self)
            )
        }
    }
}
