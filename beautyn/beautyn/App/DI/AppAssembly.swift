import Combine
import Foundation

final class AppAssembly: Assembly {
    func assemble(container: Container) {
        // MARK: - DeepLinking (ios-infra)

        let deepLinkingService: DeepLinkingService = DeepLinkingServiceImpl()
        container.register((any DeepLinkingService).self) { _ in
            deepLinkingService
        }

        // MARK: - Core

        let keychainService: KeychainService = KeychainServiceImpl()
        container.register((any KeychainService).self) { _ in
            keychainService
        }

        let defaultsService: StorageService = DefaultsStorageService()
        container.register((any StorageService).self) { _ in
            defaultsService
        }

        let sessionManager = SessionManager(keychainService: keychainService, defaultsService: defaultsService)
        container.register(SessionManager.self) { _ in
            sessionManager
        }

        container.register((any TokenProvider).self) { _ in
            sessionManager
        }

        let networkServiceImpl = NetworkServiceImpl(tokenProvider: sessionManager)
        let networkService: NetworkService = networkServiceImpl
        container.register((any NetworkService).self) { _ in
            networkService
        }

        let authRepository: AuthRepository = AuthRepositoryImpl(networkService: networkService)
        container.register((any AuthRepository).self) { _ in
            authRepository
        }

        let refreshTokenUseCase: RefreshTokenUseCase = RefreshTokenUseCaseImpl(
            repository: authRepository,
            sessionManager: sessionManager
        )
        container.register((any RefreshTokenUseCase).self) { _ in
            refreshTokenUseCase
        }

        let tokenRefresher = TokenRefresher(useCase: refreshTokenUseCase)
        container.register(TokenRefresher.self) { _ in
            tokenRefresher
        }

        networkServiceImpl.setTokenRefresher(tokenRefresher)

        // MARK: - User

        let userRemoteDataSource = UserRemoteDataSource(networkService: networkService)
        let userLocalDataSource = UserLocalDataSource(storage: defaultsService)

        let userRepository: UserRepository = UserRepositoryImpl(
            remote: userRemoteDataSource,
            local: userLocalDataSource
        )
        container.register((any UserRepository).self) { _ in
            userRepository
        }

        let getCurrentUserUseCase: GetCurrentUserUseCase = GetCurrentUserUseCaseImpl(
            repository: userRepository
        )
        container.register((any GetCurrentUserUseCase).self) { _ in
            getCurrentUserUseCase
        }

        let refreshCurrentUserUseCase: RefreshCurrentUserUseCase = RefreshCurrentUserUseCaseImpl(
            repository: userRepository
        )
        container.register((any RefreshCurrentUserUseCase).self) { _ in
            refreshCurrentUserUseCase
        }

        let clearUserUseCase: ClearUserUseCase = ClearUserUseCaseImpl(
            repository: userRepository
        )
        container.register((any ClearUserUseCase).self) { _ in
            clearUserUseCase
        }

        let logoutUseCase: LogoutUseCase = LogoutUseCaseImpl(
            repository: authRepository,
            sessionManager: sessionManager,
            clearUserUseCase: clearUserUseCase
        )
        container.register((any LogoutUseCase).self) { _ in
            logoutUseCase
        }

        let deleteAccountUseCase: DeleteAccountUseCase = DeleteAccountUseCaseImpl(
            repository: authRepository,
            sessionManager: sessionManager,
            clearUserUseCase: clearUserUseCase
        )
        container.register((any DeleteAccountUseCase).self) { _ in
            deleteAccountUseCase
        }

        let updateUserProfileUseCase: UpdateUserProfileUseCase = UpdateUserProfileUseCaseImpl(
            repository: userRepository
        )
        container.register((any UpdateUserProfileUseCase).self) { _ in
            updateUserProfileUseCase
        }

        // MARK: - User Settings

        let userSettingsRepository: UserSettingsRepository = UserSettingsRepositoryImpl(
            networkService: networkService
        )
        container.register((any UserSettingsRepository).self) { _ in
            userSettingsRepository
        }

        let getUserSettingsUseCase: GetUserSettingsUseCase = GetUserSettingsUseCaseImpl(
            repository: userSettingsRepository
        )
        container.register((any GetUserSettingsUseCase).self) { _ in
            getUserSettingsUseCase
        }

        let updateNotificationSettingsUseCase: UpdateNotificationSettingsUseCase =
            UpdateNotificationSettingsUseCaseImpl(repository: userSettingsRepository)
        container.register((any UpdateNotificationSettingsUseCase).self) { _ in
            updateNotificationSettingsUseCase
        }

        // MARK: - Saved Salons (shared — Home consumes save/unsave for the heart toggle)

        let savedSalonsRepository: SavedSalonsRepository = SavedSalonsRepositoryImpl(
            networkService: networkService
        )
        container.register((any SavedSalonsRepository).self) { _ in
            savedSalonsRepository
        }

        let savedSalonsEventBus: any SavedSalonsEventBus = SavedSalonsEventBusImpl()
        container.register((any SavedSalonsEventBus).self) { _ in
            savedSalonsEventBus
        }

        let saveSalonUseCase: SaveSalonUseCase = SaveSalonUseCaseImpl(
            repository: savedSalonsRepository,
            eventBus: savedSalonsEventBus
        )
        container.register((any SaveSalonUseCase).self) { _ in
            saveSalonUseCase
        }

        let unsaveSalonUseCase: UnsaveSalonUseCase = UnsaveSalonUseCaseImpl(
            repository: savedSalonsRepository,
            eventBus: savedSalonsEventBus
        )
        container.register((any UnsaveSalonUseCase).self) { _ in
            unsaveSalonUseCase
        }

        let getSavedSalonsUseCase: GetSavedSalonsUseCase = GetSavedSalonsUseCaseImpl(
            repository: savedSalonsRepository
        )
        container.register((any GetSavedSalonsUseCase).self) { _ in
            getSavedSalonsUseCase
        }

        // MARK: - Bookings (shared source of truth)
        //
        // One cache owned by the repository; Home, MyBookings, Booking Details and
        // the create/confirm flows all read & write through it. Registered here
        // (root) so every feature's child assembler resolves the same instance —
        // a per-feature instance would silently fail to stay in sync.

        let bookingsRepository: any BookingsRepository = BookingsRepositoryImpl(
            networkService: networkService,
            sessionManager: sessionManager
        )
        container.register((any BookingsRepository).self) { _ in
            bookingsRepository
        }

        let observeBookingsUseCase: any ObserveBookingsUseCase =
            ObserveBookingsUseCaseImpl(repository: bookingsRepository)
        container.register((any ObserveBookingsUseCase).self) { _ in
            observeBookingsUseCase
        }

        let observeBookingUseCase: any ObserveBookingUseCase =
            ObserveBookingUseCaseImpl(repository: bookingsRepository)
        container.register((any ObserveBookingUseCase).self) { _ in
            observeBookingUseCase
        }

        let refreshBookingsUseCase: any RefreshBookingsUseCase =
            RefreshBookingsUseCaseImpl(repository: bookingsRepository)
        container.register((any RefreshBookingsUseCase).self) { _ in
            refreshBookingsUseCase
        }

        let refreshBookingUseCase: any RefreshBookingUseCase =
            RefreshBookingUseCaseImpl(repository: bookingsRepository)
        container.register((any RefreshBookingUseCase).self) { _ in
            refreshBookingUseCase
        }

        let syncBookingFromCrmUseCase: any SyncBookingFromCrmUseCase =
            SyncBookingFromCrmUseCaseImpl(repository: bookingsRepository)
        container.register((any SyncBookingFromCrmUseCase).self) { _ in
            syncBookingFromCrmUseCase
        }

        // MARK: - OAuth services

        container.register((any AppleSignInService).self) { _ in
            AppleSignInServiceImpl(keychainService: keychainService)
        }

        container.register((any GoogleSignInService).self) { _ in
            GoogleSignInServiceImpl()
        }

        container.register((any AppFactory).self) { resolver in
            AppFactoryImpl(resolver: resolver)
        }

        // MARK: - Reset Password

        let resetPasswordUseCase: any ResetPasswordUseCase = ResetPasswordUseCaseImpl(
            repository: authRepository,
            sessionManager: sessionManager,
            refreshCurrentUserUseCase: refreshCurrentUserUseCase
        )
        container.register((any ResetPasswordUseCase).self) { _ in
            resetPasswordUseCase
        }

        let forgotPasswordUseCase: any ForgotPasswordUseCase = ForgotPasswordUseCaseImpl(
            repository: authRepository
        )
        container.register((any ForgotPasswordUseCase).self) { _ in
            forgotPasswordUseCase
        }

        let changePasswordUseCase: any ChangePasswordUseCase = ChangePasswordUseCaseImpl(
            repository: authRepository,
            sessionManager: sessionManager,
            refreshCurrentUserUseCase: refreshCurrentUserUseCase
        )
        container.register((any ChangePasswordUseCase).self) { _ in
            changePasswordUseCase
        }
    }
}
