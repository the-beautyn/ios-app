import Foundation

// MARK: - GetBookingByIdUseCase
//
// Fetches a single booking by its local id. Shared across features (MyBookings
// and the EasyWeek booking flow, which fetches the full booking after confirm),
// so it is registered in the root container.

protocol GetBookingByIdUseCase {
    func execute(id: String) async throws -> Booking
}

// MARK: - GetBookingByIdUseCaseImpl

final class GetBookingByIdUseCaseImpl: GetBookingByIdUseCase {

    private let repository: MyBookingsRepository

    init(repository: MyBookingsRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws -> Booking {
        try await repository.getBooking(id: id)
    }
}
