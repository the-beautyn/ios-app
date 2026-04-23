import Foundation

// MARK: - ResetPasswordAssembly

final class ResetPasswordAssembly: Assembly {
    func assemble(container: Container) {
        container.register((any ResetPasswordControllerFactory).self) { resolver in
            ResetPasswordControllerFactoryImpl(assembler: resolver)
        }

        container.register((any ResetPasswordFactory).self) { resolver in
            ResetPasswordFactoryImpl(resolver: resolver)
        }
    }
}
