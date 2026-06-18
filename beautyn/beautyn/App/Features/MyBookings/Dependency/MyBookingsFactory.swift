import Foundation

// MARK: - Protocol

protocol MyBookingsFactory: ResolverInjector {
    var controllerFactory: any MyBookingsControllerFactory { get }
}

// MARK: - Default implementations

extension MyBookingsFactory {
    var controllerFactory: any MyBookingsControllerFactory { resolver.require((any MyBookingsControllerFactory).self) }
}

// MARK: - Implementation

final class MyBookingsFactoryImpl: ResolverInjectorImpl, MyBookingsFactory {}
