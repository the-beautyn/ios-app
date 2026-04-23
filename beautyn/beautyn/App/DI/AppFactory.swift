import Foundation

// MARK: - Protocol

protocol AppFactory: ResolverInjector {
    var deepLinkingService: any DeepLinkingService { get }
    var keychainService: any KeychainService { get }
    var storageService: any StorageService { get }
    var sessionManager: SessionManager { get }
    var tokenProvider: any TokenProvider { get }
    var networkService: any NetworkService { get }
    var authRepository: any AuthRepository { get }
    var refreshTokenUseCase: any RefreshTokenUseCase { get }
    var tokenRefresher: TokenRefresher { get }
    var userRepository: any UserRepository { get }
    var getMeUseCase: any GetMeUseCase { get }
    var appleSignInService: any AppleSignInService { get }
    var googleSignInService: any GoogleSignInService { get }
    var resetPasswordUseCase: any ResetPasswordUseCase { get }
    var forgotPasswordUseCase: any ForgotPasswordUseCase { get }
}

// MARK: - Default implementations

extension AppFactory {
    var deepLinkingService: any DeepLinkingService { resolver.require((any DeepLinkingService).self) }
    var keychainService: any KeychainService { resolver.require((any KeychainService).self) }
    var storageService: any StorageService { resolver.require((any StorageService).self) }
    var sessionManager: SessionManager { resolver.require(SessionManager.self) }
    var tokenProvider: any TokenProvider { resolver.require((any TokenProvider).self) }
    var networkService: any NetworkService { resolver.require((any NetworkService).self) }
    var authRepository: any AuthRepository { resolver.require((any AuthRepository).self) }
    var refreshTokenUseCase: any RefreshTokenUseCase { resolver.require((any RefreshTokenUseCase).self) }
    var tokenRefresher: TokenRefresher { resolver.require(TokenRefresher.self) }
    var userRepository: any UserRepository { resolver.require((any UserRepository).self) }
    var getMeUseCase: any GetMeUseCase { resolver.require((any GetMeUseCase).self) }
    var appleSignInService: any AppleSignInService { resolver.require((any AppleSignInService).self) }
    var googleSignInService: any GoogleSignInService { resolver.require((any GoogleSignInService).self) }
    var resetPasswordUseCase: any ResetPasswordUseCase { resolver.require((any ResetPasswordUseCase).self) }
    var forgotPasswordUseCase: any ForgotPasswordUseCase { resolver.require((any ForgotPasswordUseCase).self) }
}

// MARK: - Implementation

final class AppFactoryImpl: ResolverInjectorImpl, AppFactory {}
