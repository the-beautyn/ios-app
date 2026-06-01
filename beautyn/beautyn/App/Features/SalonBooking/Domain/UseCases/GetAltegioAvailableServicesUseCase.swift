import Foundation

// MARK: - GetAltegioAvailableServicesUseCase

protocol GetAltegioAvailableServicesUseCase {
    func execute(
        salonId: String,
        selectedServiceIds: [String],
        workerId: String?
    ) async throws -> Set<String>
}

// MARK: - GetAltegioAvailableServicesUseCaseImpl

final class GetAltegioAvailableServicesUseCaseImpl: GetAltegioAvailableServicesUseCase {

    private let repository: AltegioBookingRepository

    init(repository: AltegioBookingRepository) {
        self.repository = repository
    }

    func execute(
        salonId: String,
        selectedServiceIds: [String],
        workerId: String?
    ) async throws -> Set<String> {
        try await repository.availableServiceIds(
            salonId: salonId,
            selectedServiceIds: selectedServiceIds,
            workerId: workerId
        )
    }
}
