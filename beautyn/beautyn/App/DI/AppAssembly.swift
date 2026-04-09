import Foundation

final class AppAssembly: Assembly {
    func assemble(container: Container) {
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

        let networkService: NetworkService = NetworkServiceImpl(tokenProvider: sessionManager)
        container.register((any NetworkService).self) { _ in
            networkService
        }

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
    }
}
