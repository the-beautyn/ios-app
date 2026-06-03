import Foundation

// MARK: - GetAltegioAvailableServicesUseCase

protocol GetAltegioAvailableServicesUseCase {
    func execute(
        salonId: String,
        selectedServiceIds: [String],
        workerId: String?,
        datetime: String?
    ) async throws -> Set<String>
}

extension GetAltegioAvailableServicesUseCase {
    func execute(
        salonId: String,
        selectedServiceIds: [String],
        workerId: String?
    ) async throws -> Set<String> {
        try await execute(
            salonId: salonId,
            selectedServiceIds: selectedServiceIds,
            workerId: workerId,
            datetime: nil
        )
    }
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
        workerId: String?,
        datetime: String?
    ) async throws -> Set<String> {
        try await repository.availableServiceIds(
            salonId: salonId,
            selectedServiceIds: selectedServiceIds,
            workerId: workerId,
            datetime: datetime
        )
    }
}
