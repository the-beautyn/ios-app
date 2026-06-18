import Foundation

// MARK: - RefreshBookingUseCase
//
// Fetches a single booking by local id into the cache and returns it. Replaces
// the old `GetBookingByIdUseCase` (shared with the EasyWeek confirm flow, which
// needs the full booking back). The CRM "Make changes" refresh variant builds on
// this in a later task.

@MainActor
protocol RefreshBookingUseCase {
    @discardableResult
    func execute(id: String) async throws -> Booking
}

// MARK: - RefreshBookingUseCaseImpl

@MainActor
final class RefreshBookingUseCaseImpl: RefreshBookingUseCase {

    private let repository: BookingsRepository

    init(repository: BookingsRepository) {
        self.repository = repository
    }

    @discardableResult
    func execute(id: String) async throws -> Booking {
        try await repository.refreshBooking(id: id)
    }
}
