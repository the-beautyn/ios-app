import Foundation

// MARK: - CreateAltegioBookingUseCase

protocol CreateAltegioBookingUseCase {
    /// Create the booking record and return the full backend `Booking`. `workerId`
    /// nil = "any team member".
    func execute(
        salonId: String,
        workerId: String?,
        serviceIds: [String],
        datetime: String,
        comment: String?
    ) async throws -> Booking
}

// MARK: - CreateAltegioBookingUseCaseImpl

final class CreateAltegioBookingUseCaseImpl: CreateAltegioBookingUseCase {

    private let repository: AltegioBookingRepository
    private let bookingsRepository: any BookingsRepository

    init(repository: AltegioBookingRepository, bookingsRepository: any BookingsRepository) {
        self.repository = repository
        self.bookingsRepository = bookingsRepository
    }

    func execute(
        salonId: String,
        workerId: String?,
        serviceIds: [String],
        datetime: String,
        comment: String?
    ) async throws -> Booking {
        let created = try await repository.createBooking(
            salonId: salonId,
            workerId: workerId,
            serviceIds: serviceIds,
            datetime: datetime,
            comment: comment
        )
        // Fetch the created booking into the source of truth and return it: the
        // backend read the new record back from Altegio at create, so this carries
        // the CRM data (incl. the short link). Home / MyBookings observe the cache,
        // and the details screen navigates straight off this Booking — same as the
        // EasyWeek confirm flow.
        return try await bookingsRepository.refreshBooking(id: created.bookingId)
    }
}
