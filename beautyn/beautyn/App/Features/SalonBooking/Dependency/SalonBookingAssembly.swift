import Foundation

// MARK: - SalonBookingAssembly

final class SalonBookingAssembly: Assembly {
    func assemble(container: Container) {
        container.register((any SalonRepository).self) { resolver in
            SalonRepositoryImpl(
                networkService: resolver.require((any NetworkService).self)
            )
        }

        container.register((any AltegioBookingRepository).self) { resolver in
            AltegioBookingRepositoryImpl(
                networkService: resolver.require((any NetworkService).self)
            )
        }

        container.register((any GetSalonByIdUseCase).self) { resolver in
            GetSalonByIdUseCaseImpl(
                repository: resolver.require((any SalonRepository).self)
            )
        }

        container.register((any GetAltegioAvailableServicesUseCase).self) { resolver in
            GetAltegioAvailableServicesUseCaseImpl(
                repository: resolver.require((any AltegioBookingRepository).self)
            )
        }

        container.register((any GetAltegioAvailableWorkersUseCase).self) { resolver in
            GetAltegioAvailableWorkersUseCaseImpl(
                repository: resolver.require((any AltegioBookingRepository).self)
            )
        }

        container.register((any GetAltegioBookingDatesUseCase).self) { resolver in
            GetAltegioBookingDatesUseCaseImpl(
                repository: resolver.require((any AltegioBookingRepository).self)
            )
        }

        container.register((any GetAltegioTimeSlotsUseCase).self) { resolver in
            GetAltegioTimeSlotsUseCaseImpl(
                repository: resolver.require((any AltegioBookingRepository).self)
            )
        }

        container.register((any CreateAltegioBookingUseCase).self) { resolver in
            CreateAltegioBookingUseCaseImpl(
                repository: resolver.require((any AltegioBookingRepository).self)
            )
        }

        container.register((any GetSalonShareUseCase).self) { resolver in
            GetSalonShareUseCaseImpl(
                repository: resolver.require((any SalonRepository).self)
            )
        }

        container.register((any SalonBookingControllerFactory).self) { resolver in
            SalonBookingControllerFactoryImpl(assembler: resolver)
        }

        container.register((any SalonBookingFactory).self) { resolver in
            SalonBookingFactoryImpl(resolver: resolver)
        }
    }
}
