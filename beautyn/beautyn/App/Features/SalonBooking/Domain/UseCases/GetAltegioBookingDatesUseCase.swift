import Foundation

// MARK: - GetAltegioBookingDatesUseCase

protocol GetAltegioBookingDatesUseCase {
    /// Bookable calendar days in `[dateFrom, dateTo]` (both `yyyy-MM-dd`).
    /// `serviceIds` / `workerId` narrow availability.
    func execute(
        salonId: String,
        serviceIds: [String],
        workerId: String?,
        dateFrom: String,
        dateTo: String
    ) async throws -> [Date]
}

// MARK: - GetAltegioBookingDatesUseCaseImpl

final class GetAltegioBookingDatesUseCaseImpl: GetAltegioBookingDatesUseCase {

    private let repository: AltegioBookingRepository

    init(repository: AltegioBookingRepository) {
        self.repository = repository
    }

    func execute(
        salonId: String,
        serviceIds: [String],
        workerId: String?,
        dateFrom: String,
        dateTo: String
    ) async throws -> [Date] {
        try await repository.availableDates(
            salonId: salonId,
            serviceIds: serviceIds,
            workerId: workerId,
            dateFrom: dateFrom,
            dateTo: dateTo
        )
    }
}
