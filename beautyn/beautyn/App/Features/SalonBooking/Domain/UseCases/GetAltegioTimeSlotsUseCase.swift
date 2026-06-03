import Foundation

// MARK: - GetAltegioTimeSlotsUseCase

protocol GetAltegioTimeSlotsUseCase {
    /// Available time slots for `date` (`yyyy-MM-dd`). `serviceIds` / `workerId`
    /// narrow availability.
    func execute(
        salonId: String,
        date: String,
        workerId: String?,
        serviceIds: [String]
    ) async throws -> [AltegioBookingSlot]
}

// MARK: - GetAltegioTimeSlotsUseCaseImpl

final class GetAltegioTimeSlotsUseCaseImpl: GetAltegioTimeSlotsUseCase {

    private let repository: AltegioBookingRepository

    init(repository: AltegioBookingRepository) {
        self.repository = repository
    }

    func execute(
        salonId: String,
        date: String,
        workerId: String?,
        serviceIds: [String]
    ) async throws -> [AltegioBookingSlot] {
        try await repository.timeSlots(
            salonId: salonId,
            date: date,
            workerId: workerId,
            serviceIds: serviceIds
        )
    }
}
