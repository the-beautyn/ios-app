import Foundation

// MARK: - Protocol

protocol MainFactory: ResolverInjector {
    var homeFeedRepository: any HomeFeedRepository { get }
    var getHomeFeedUseCase: any GetHomeFeedUseCase { get }
    var controllerFactory: any MainControllerFactory { get }
}

// MARK: - Default implementations

extension MainFactory {
    var homeFeedRepository: any HomeFeedRepository { resolver.require((any HomeFeedRepository).self) }
    var getHomeFeedUseCase: any GetHomeFeedUseCase { resolver.require((any GetHomeFeedUseCase).self) }
    var controllerFactory: any MainControllerFactory { resolver.require((any MainControllerFactory).self) }
}

// MARK: - Implementation

final class MainFactoryImpl: ResolverInjectorImpl, MainFactory {}
