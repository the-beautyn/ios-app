import Foundation

// MARK: - Protocol

protocol SalonBookingFactory: ResolverInjector {
    var salonRepository: any SalonRepository { get }
    var getSalonByIdUseCase: any GetSalonByIdUseCase { get }
    var getSalonShareUseCase: any GetSalonShareUseCase { get }
    var controllerFactory: any SalonBookingControllerFactory { get }
}

// MARK: - Default implementations

extension SalonBookingFactory {
    var salonRepository: any SalonRepository { resolver.require((any SalonRepository).self) }
    var getSalonByIdUseCase: any GetSalonByIdUseCase { resolver.require((any GetSalonByIdUseCase).self) }
    var getSalonShareUseCase: any GetSalonShareUseCase { resolver.require((any GetSalonShareUseCase).self) }
    var controllerFactory: any SalonBookingControllerFactory { resolver.require((any SalonBookingControllerFactory).self) }
}

// MARK: - Implementation

final class SalonBookingFactoryImpl: ResolverInjectorImpl, SalonBookingFactory {}
