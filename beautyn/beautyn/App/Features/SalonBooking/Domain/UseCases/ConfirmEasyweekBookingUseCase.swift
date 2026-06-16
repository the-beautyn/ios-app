import Foundation

// MARK: - ConfirmEasyweekBookingUseCase

protocol ConfirmEasyweekBookingUseCase {
    /// Confirm a completed EasyWeek widget booking (persist on the backend),
    /// notify the booking lists, and return the full local booking.
    func execute(salonId: String, bookingUuid: String) async throws -> Booking
}

// MARK: - ConfirmEasyweekBookingUseCaseImpl

final class ConfirmEasyweekBookingUseCaseImpl: ConfirmEasyweekBookingUseCase {

    private let repository: EasyweekBookingRepository
    private let getBookingByIdUseCase: any GetBookingByIdUseCase
    private let bookingEventBus: any BookingEventBus

    init(
        repository: EasyweekBookingRepository,
        getBookingByIdUseCase: any GetBookingByIdUseCase,
        bookingEventBus: any BookingEventBus
    ) {
        self.repository = repository
        self.getBookingByIdUseCase = getBookingByIdUseCase
        self.bookingEventBus = bookingEventBus
    }

    func execute(salonId: String, bookingUuid: String) async throws -> Booking {
        let bookingId = try await repository.confirm(salonId: salonId, bookingUuid: bookingUuid)
        // Let the Home and MyBookings screens refresh themselves.
        bookingEventBus.notifyBookingCreated(
            BookingCreatedEvent(bookingId: bookingId, salonId: salonId)
        )
        // Fetch the full booking (services + price) for the details screen.
        return try await getBookingByIdUseCase.execute(id: bookingId)
    }
}
