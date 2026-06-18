import Foundation

// MARK: - RefreshBookingsUseCase
//
// Fetches a category of bookings (nil = all) from the backend into the cache.
// Replaces the old `GetMyBookingsUseCase` — display is now driven by
// `ObserveBookingsUseCase`, so this is a command that returns nothing.

@MainActor
protocol RefreshBookingsUseCase {
    func execute(category: BookingCategory?) async throws
}

// MARK: - RefreshBookingsUseCaseImpl

@MainActor
final class RefreshBookingsUseCaseImpl: RefreshBookingsUseCase {

    private let repository: BookingsRepository

    init(repository: BookingsRepository) {
        self.repository = repository
    }

    func execute(category: BookingCategory?) async throws {
        try await repository.refreshBookings(category)
    }
}
