import Foundation

// MARK: - Protocol

protocol SalonBookingFactory: ResolverInjector {
    var salonRepository: any SalonRepository { get }
    var getSalonByIdUseCase: any GetSalonByIdUseCase { get }
    var getSalonShareUseCase: any GetSalonShareUseCase { get }
    var getAltegioAvailableServicesUseCase: any GetAltegioAvailableServicesUseCase { get }
    var getAltegioAvailableWorkersUseCase: any GetAltegioAvailableWorkersUseCase { get }
    var getAltegioBookingDatesUseCase: any GetAltegioBookingDatesUseCase { get }
    var getAltegioTimeSlotsUseCase: any GetAltegioTimeSlotsUseCase { get }
    var controllerFactory: any SalonBookingControllerFactory { get }
}

// MARK: - Default implementations

extension SalonBookingFactory {
    var salonRepository: any SalonRepository { resolver.require((any SalonRepository).self) }
    var getSalonByIdUseCase: any GetSalonByIdUseCase { resolver.require((any GetSalonByIdUseCase).self) }
    var getSalonShareUseCase: any GetSalonShareUseCase { resolver.require((any GetSalonShareUseCase).self) }
    var getAltegioAvailableServicesUseCase: any GetAltegioAvailableServicesUseCase {
        resolver.require((any GetAltegioAvailableServicesUseCase).self)
    }
    var getAltegioAvailableWorkersUseCase: any GetAltegioAvailableWorkersUseCase {
        resolver.require((any GetAltegioAvailableWorkersUseCase).self)
    }
    var getAltegioBookingDatesUseCase: any GetAltegioBookingDatesUseCase {
        resolver.require((any GetAltegioBookingDatesUseCase).self)
    }
    var getAltegioTimeSlotsUseCase: any GetAltegioTimeSlotsUseCase {
        resolver.require((any GetAltegioTimeSlotsUseCase).self)
    }
    var controllerFactory: any SalonBookingControllerFactory { resolver.require((any SalonBookingControllerFactory).self) }
}

// MARK: - Implementation

final class SalonBookingFactoryImpl: ResolverInjectorImpl, SalonBookingFactory {}
