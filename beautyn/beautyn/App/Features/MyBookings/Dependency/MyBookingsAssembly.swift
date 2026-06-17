import Foundation

// MARK: - MyBookingsAssembly

final class MyBookingsAssembly: Assembly {
    func assemble(container: Container) {
        // The bookings repository + observe/refresh use cases live in AppAssembly
        // (shared source of truth). This feature only wires its own UI factories.

        container.register((any MyBookingsControllerFactory).self) { resolver in
            MyBookingsControllerFactoryImpl(assembler: resolver)
        }

        container.register((any MyBookingsFactory).self) { resolver in
            MyBookingsFactoryImpl(resolver: resolver)
        }
    }
}
