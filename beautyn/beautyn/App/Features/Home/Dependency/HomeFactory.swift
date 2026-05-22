import Foundation

// MARK: - Protocol

protocol HomeFactory: ResolverInjector {
    var homeFeedRepository: any HomeFeedRepository { get }
    var getHomeFeedUseCase: any GetHomeFeedUseCase { get }
    var controllerFactory: any HomeControllerFactory { get }
}

// MARK: - Default implementations

extension HomeFactory {
    var homeFeedRepository: any HomeFeedRepository { resolver.require((any HomeFeedRepository).self) }
    var getHomeFeedUseCase: any GetHomeFeedUseCase { resolver.require((any GetHomeFeedUseCase).self) }
    var controllerFactory: any HomeControllerFactory { resolver.require((any HomeControllerFactory).self) }
}

// MARK: - Implementation

final class HomeFactoryImpl: ResolverInjectorImpl, HomeFactory {}
