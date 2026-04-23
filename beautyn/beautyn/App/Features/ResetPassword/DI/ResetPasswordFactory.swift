import Foundation

// MARK: - Protocol

protocol ResetPasswordFactory: ResolverInjector {
    var controllerFactory: any ResetPasswordControllerFactory { get }
}

// MARK: - Default implementations

extension ResetPasswordFactory {
    var controllerFactory: any ResetPasswordControllerFactory { resolver.require((any ResetPasswordControllerFactory).self) }
}

// MARK: - Implementation

final class ResetPasswordFactoryImpl: ResolverInjectorImpl, ResetPasswordFactory {}
