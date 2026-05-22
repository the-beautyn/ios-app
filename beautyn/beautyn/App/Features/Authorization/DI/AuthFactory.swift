import Foundation

// MARK: - Protocol

protocol AuthFactory: ResolverInjector {
    var checkEmailUseCase: any CheckEmailUseCase { get }
    var loginUseCase: any LoginUseCase { get }
    var registerUseCase: any RegisterUseCase { get }
    var oauthSignInUseCase: any OAuthSignInUseCase { get }
    var controllerFactory: any AuthControllerFactory { get }
}

// MARK: - Default implementations

extension AuthFactory {
    var checkEmailUseCase: any CheckEmailUseCase { resolver.require((any CheckEmailUseCase).self) }
    var loginUseCase: any LoginUseCase { resolver.require((any LoginUseCase).self) }
    var registerUseCase: any RegisterUseCase { resolver.require((any RegisterUseCase).self) }
    var oauthSignInUseCase: any OAuthSignInUseCase { resolver.require((any OAuthSignInUseCase).self) }
    var controllerFactory: any AuthControllerFactory { resolver.require((any AuthControllerFactory).self) }
}

// MARK: - Implementation

final class AuthFactoryImpl: ResolverInjectorImpl, AuthFactory {}
