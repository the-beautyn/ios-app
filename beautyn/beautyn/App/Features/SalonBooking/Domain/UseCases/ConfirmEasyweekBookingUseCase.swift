import Foundation

// MARK: - ConfirmEasyweekBookingUseCase

protocol ConfirmEasyweekBookingUseCase {
    /// Confirm a completed EasyWeek widget booking (persist on the backend), cache
    /// the full booking so every screen sees it, and return it.
    func execute(salonId: String, bookingUuid: String) async throws -> Booking
}

// MARK: - ConfirmEasyweekBookingUseCaseImpl

final class ConfirmEasyweekBookingUseCaseImpl: ConfirmEasyweekBookingUseCase {

    private let repository: EasyweekBookingRepository
    private let bookingsRepository: any BookingsRepository

    init(
        repository: EasyweekBookingRepository,
        bookingsRepository: any BookingsRepository
    ) {
        self.repository = repository
        self.bookingsRepository = bookingsRepository
    }

    func execute(salonId: String, bookingUuid: String) async throws -> Booking {
        let bookingId = try await repository.confirm(salonId: salonId, bookingUuid: bookingUuid)
        // Fetch the full booking (services + price) and cache it — the bookings
        // source of truth then emits it to Home / MyBookings / the details screen.
        return try await bookingsRepository.refreshBooking(id: bookingId)
    }
}
