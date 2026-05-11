import Foundation

// MARK: - PhoneVerificationAssembly

final class PhoneVerificationAssembly: Assembly {
    func assemble(container: Container) {
        container.register((any SendPhoneOTPUseCase).self) { resolver in
            SendPhoneOTPUseCaseImpl(
                repository: resolver.require((any AuthRepository).self)
            )
        }

        container.register((any VerifyPhoneOTPUseCase).self) { resolver in
            VerifyPhoneOTPUseCaseImpl(
                repository: resolver.require((any AuthRepository).self),
                sessionManager: resolver.require(SessionManager.self),
                refreshCurrentUserUseCase: resolver.require((any RefreshCurrentUserUseCase).self)
            )
        }

        container.register((any PhoneVerificationControllerFactory).self) { resolver in
            PhoneVerificationControllerFactoryImpl(assembler: resolver)
        }

        container.register((any PhoneVerificationFactory).self) { resolver in
            PhoneVerificationFactoryImpl(resolver: resolver)
        }
    }
}
