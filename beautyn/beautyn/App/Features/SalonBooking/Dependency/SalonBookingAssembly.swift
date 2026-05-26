import Foundation

// MARK: - SalonBookingAssembly

final class SalonBookingAssembly: Assembly {
    func assemble(container: Container) {
        container.register((any SalonRepository).self) { resolver in
            SalonRepositoryImpl(
                networkService: resolver.require((any NetworkService).self)
            )
        }

        container.register((any GetSalonByIdUseCase).self) { resolver in
            GetSalonByIdUseCaseImpl(
                repository: resolver.require((any SalonRepository).self)
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
