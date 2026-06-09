import Foundation

// MARK: - Protocol

protocol MyBookingsFactory: ResolverInjector {
    var myBookingsRepository: any MyBookingsRepository { get }
    var getMyBookingsUseCase: any GetMyBookingsUseCase { get }
    var controllerFactory: any MyBookingsControllerFactory { get }
}

// MARK: - Default implementations

extension MyBookingsFactory {
    var myBookingsRepository: any MyBookingsRepository { resolver.require((any MyBookingsRepository).self) }
    var getMyBookingsUseCase: any GetMyBookingsUseCase { resolver.require((any GetMyBookingsUseCase).self) }
    var controllerFactory: any MyBookingsControllerFactory { resolver.require((any MyBookingsControllerFactory).self) }
}

// MARK: - Implementation

final class MyBookingsFactoryImpl: ResolverInjectorImpl, MyBookingsFactory {}
