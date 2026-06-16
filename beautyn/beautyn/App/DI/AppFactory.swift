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
    var logoutUseCase: any LogoutUseCase { get }
    var deleteAccountUseCase: any DeleteAccountUseCase { get }
    var tokenRefresher: TokenRefresher { get }
    var getCurrentUserUseCase: any GetCurrentUserUseCase { get }
    var getBookingByIdUseCase: any GetBookingByIdUseCase { get }
    var refreshCurrentUserUseCase: any RefreshCurrentUserUseCase { get }
    var clearUserUseCase: any ClearUserUseCase { get }
    var updateUserProfileUseCase: any UpdateUserProfileUseCase { get }
    var getUserSettingsUseCase: any GetUserSettingsUseCase { get }
    var updateNotificationSettingsUseCase: any UpdateNotificationSettingsUseCase { get }
    var appleSignInService: any AppleSignInService { get }
    var googleSignInService: any GoogleSignInService { get }
    var resetPasswordUseCase: any ResetPasswordUseCase { get }
    var forgotPasswordUseCase: any ForgotPasswordUseCase { get }
    var changePasswordUseCase: any ChangePasswordUseCase { get }
    var saveSalonUseCase: any SaveSalonUseCase { get }
    var unsaveSalonUseCase: any UnsaveSalonUseCase { get }
    var getSavedSalonsUseCase: any GetSavedSalonsUseCase { get }
    var savedSalonsEventBus: any SavedSalonsEventBus { get }
    var bookingEventBus: any BookingEventBus { get }
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
    var logoutUseCase: any LogoutUseCase { resolver.require((any LogoutUseCase).self) }
    var deleteAccountUseCase: any DeleteAccountUseCase { resolver.require((any DeleteAccountUseCase).self) }
    var tokenRefresher: TokenRefresher { resolver.require(TokenRefresher.self) }
    var getCurrentUserUseCase: any GetCurrentUserUseCase { resolver.require((any GetCurrentUserUseCase).self) }
    var getBookingByIdUseCase: any GetBookingByIdUseCase { resolver.require((any GetBookingByIdUseCase).self) }
    var refreshCurrentUserUseCase: any RefreshCurrentUserUseCase { resolver.require((any RefreshCurrentUserUseCase).self) }
    var clearUserUseCase: any ClearUserUseCase { resolver.require((any ClearUserUseCase).self) }
    var updateUserProfileUseCase: any UpdateUserProfileUseCase { resolver.require((any UpdateUserProfileUseCase).self) }
    var getUserSettingsUseCase: any GetUserSettingsUseCase { resolver.require((any GetUserSettingsUseCase).self) }
    var updateNotificationSettingsUseCase: any UpdateNotificationSettingsUseCase { resolver.require((any UpdateNotificationSettingsUseCase).self) }
    var appleSignInService: any AppleSignInService { resolver.require((any AppleSignInService).self) }
    var googleSignInService: any GoogleSignInService { resolver.require((any GoogleSignInService).self) }
    var resetPasswordUseCase: any ResetPasswordUseCase { resolver.require((any ResetPasswordUseCase).self) }
    var forgotPasswordUseCase: any ForgotPasswordUseCase { resolver.require((any ForgotPasswordUseCase).self) }
    var changePasswordUseCase: any ChangePasswordUseCase { resolver.require((any ChangePasswordUseCase).self) }
    var saveSalonUseCase: any SaveSalonUseCase { resolver.require((any SaveSalonUseCase).self) }
    var unsaveSalonUseCase: any UnsaveSalonUseCase { resolver.require((any UnsaveSalonUseCase).self) }
    var getSavedSalonsUseCase: any GetSavedSalonsUseCase { resolver.require((any GetSavedSalonsUseCase).self) }
    var savedSalonsEventBus: any SavedSalonsEventBus { resolver.require((any SavedSalonsEventBus).self) }
    var bookingEventBus: any BookingEventBus { resolver.require((any BookingEventBus).self) }
}

// MARK: - Implementation

final class AppFactoryImpl: ResolverInjectorImpl, AppFactory {}
