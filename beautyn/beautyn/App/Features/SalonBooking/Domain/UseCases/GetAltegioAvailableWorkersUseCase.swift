import Foundation

// MARK: - GetAltegioAvailableWorkersUseCase

protocol GetAltegioAvailableWorkersUseCase {
    /// Workers the salon can book given the optional service / datetime filter,
    /// each with a `isBookable` flag and (when `includeSlots`) their next
    /// available slots. Empty filters → every Altegio-connected worker.
    func execute(
        salonId: String,
        serviceIds: [String],
        datetime: String?,
        includeSlots: Bool
    ) async throws -> [AltegioBookableWorker]
}

// MARK: - GetAltegioAvailableWorkersUseCaseImpl

final class GetAltegioAvailableWorkersUseCaseImpl: GetAltegioAvailableWorkersUseCase {

    private let repository: AltegioBookingRepository

    init(repository: AltegioBookingRepository) {
        self.repository = repository
    }

    func execute(
        salonId: String,
        serviceIds: [String],
        datetime: String?,
        includeSlots: Bool
    ) async throws -> [AltegioBookableWorker] {
        try await repository.availableWorkers(
            salonId: salonId,
            serviceIds: serviceIds,
            datetime: datetime,
            includeSlots: includeSlots
        )
    }
}
