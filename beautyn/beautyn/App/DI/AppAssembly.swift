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

        let userRepository: UserRepository = UserRepositoryImpl(
            networkService: networkService,
            defaultsService: defaultsService
        )
        container.register((any UserRepository).self) { _ in
            userRepository
        }

        let getMeUseCase: GetMeUseCase = GetMeUseCaseImpl(userRepository: userRepository)
        container.register((any GetMeUseCase).self) { _ in
            getMeUseCase
        }

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
            getMeUseCase: getMeUseCase
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
    }
}
