import Foundation

// MARK: - Protocol

protocol ProfileFactory: ResolverInjector {
    var controllerFactory: any ProfileControllerFactory { get }
}

// MARK: - Default implementations

extension ProfileFactory {
    var controllerFactory: any ProfileControllerFactory { resolver.require((any ProfileControllerFactory).self) }
}

// MARK: - Implementation

final class ProfileFactoryImpl: ResolverInjectorImpl, ProfileFactory {}
