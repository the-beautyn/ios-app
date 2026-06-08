import Foundation

// MARK: - CreateAltegioBookingUseCase

protocol CreateAltegioBookingUseCase {
    /// Create the booking record. `workerId` nil = "any team member".
    func execute(
        salonId: String,
        workerId: String?,
        serviceIds: [String],
        datetime: String,
        comment: String?
    ) async throws -> CreatedBooking
}

// MARK: - CreateAltegioBookingUseCaseImpl

final class CreateAltegioBookingUseCaseImpl: CreateAltegioBookingUseCase {

    private let repository: AltegioBookingRepository

    init(repository: AltegioBookingRepository) {
        self.repository = repository
    }

    func execute(
        salonId: String,
        workerId: String?,
        serviceIds: [String],
        datetime: String,
        comment: String?
    ) async throws -> CreatedBooking {
        try await repository.createBooking(
            salonId: salonId,
            workerId: workerId,
            serviceIds: serviceIds,
            datetime: datetime,
            comment: comment
        )
    }
}
