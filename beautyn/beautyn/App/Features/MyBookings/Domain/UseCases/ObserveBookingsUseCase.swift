import Combine
import Foundation

// MARK: - ObserveBookingsUseCase
//
// Reactive read of the whole cached bookings list (the My Bookings screen splits
// it into tabs locally). The presentation layer depends on this use case, never
// on the repository directly.

@MainActor
protocol ObserveBookingsUseCase {
    func execute() -> AnyPublisher<[Booking], Never>
}

// MARK: - ObserveBookingsUseCaseImpl

@MainActor
final class ObserveBookingsUseCaseImpl: ObserveBookingsUseCase {

    private let repository: BookingsRepository

    init(repository: BookingsRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[Booking], Never> {
        repository.observeBookings()
    }
}
