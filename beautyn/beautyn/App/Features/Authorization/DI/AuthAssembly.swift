import Foundation

// MARK: - AuthAssembly

final class AuthAssembly: Assembly {
    func assemble(container: Container) {
        container.register((any AuthRepository).self) { resolver in
            AuthRepositoryImpl(
                networkService: resolver.require((any NetworkService).self)
            )
        }

        container.register((any CheckEmailUseCase).self) { resolver in
            CheckEmailUseCaseImpl(
                repository: resolver.require((any AuthRepository).self)
            )
        }

        container.register((any LoginUseCase).self) { resolver in
            LoginUseCaseImpl(
                repository: resolver.require((any AuthRepository).self),
                sessionManager: resolver.require(SessionManager.self),
                getMeUseCase: resolver.require((any GetMeUseCase).self)
            )
        }

        container.register((any RegisterUseCase).self) { resolver in
            RegisterUseCaseImpl(
                repository: resolver.require((any AuthRepository).self),
                sessionManager: resolver.require(SessionManager.self),
                getMeUseCase: resolver.require((any GetMeUseCase).self)
            )
        }

        container.register((any OAuthSignInUseCase).self) { resolver in
            OAuthSignInUseCaseImpl(
                repository: resolver.require((any AuthRepository).self),
                sessionManager: resolver.require(SessionManager.self),
                getMeUseCase: resolver.require((any GetMeUseCase).self)
            )
        }

        container.register((any ForgotPasswordUseCase).self) { resolver in
            ForgotPasswordUseCaseImpl(
                repository: resolver.require((any AuthRepository).self)
            )
        }

        container.register((any SendPhoneOTPUseCase).self) { resolver in
            SendPhoneOTPUseCaseImpl(
                repository: resolver.require((any AuthRepository).self)
            )
        }

        container.register((any VerifyPhoneOTPUseCase).self) { resolver in
            VerifyPhoneOTPUseCaseImpl(
                repository: resolver.require((any AuthRepository).self)
            )
        }

        container.register((any AuthControllerFactory).self) { resolver in
            AuthControllerFactoryImpl(assembler: resolver)
        }
    }
}
