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
    private let bookingEventBus: any BookingEventBus

    init(repository: AltegioBookingRepository, bookingEventBus: any BookingEventBus) {
        self.repository = repository
        self.bookingEventBus = bookingEventBus
    }

    func execute(
        salonId: String,
        workerId: String?,
        serviceIds: [String],
        datetime: String,
        comment: String?
    ) async throws -> CreatedBooking {
        let booking = try await repository.createBooking(
            salonId: salonId,
            workerId: workerId,
            serviceIds: serviceIds,
            datetime: datetime,
            comment: comment
        )
        // Let the Home and MyBookings screens refresh themselves.
        bookingEventBus.notifyBookingCreated(
            BookingCreatedEvent(bookingId: booking.bookingId, salonId: salonId)
        )
        return booking
    }
}
