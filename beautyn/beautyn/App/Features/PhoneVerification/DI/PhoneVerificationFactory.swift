import Foundation

// MARK: - Protocol

protocol PhoneVerificationFactory: ResolverInjector {
    var sendPhoneOTPUseCase: any SendPhoneOTPUseCase { get }
    var verifyPhoneOTPUseCase: any VerifyPhoneOTPUseCase { get }
    var controllerFactory: any PhoneVerificationControllerFactory { get }
}

// MARK: - Default implementations

extension PhoneVerificationFactory {
    var sendPhoneOTPUseCase: any SendPhoneOTPUseCase { resolver.require((any SendPhoneOTPUseCase).self) }
    var verifyPhoneOTPUseCase: any VerifyPhoneOTPUseCase { resolver.require((any VerifyPhoneOTPUseCase).self) }
    var controllerFactory: any PhoneVerificationControllerFactory { resolver.require((any PhoneVerificationControllerFactory).self) }
}

// MARK: - Implementation

final class PhoneVerificationFactoryImpl: ResolverInjectorImpl, PhoneVerificationFactory {}
