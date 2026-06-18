import Combine
import Foundation

// MARK: - ObserveBookingUseCase
//
// Reactive read of a single booking by id (Home's next appointment + Booking
// Details). Emits `nil` until the booking is cached / after it's removed.

@MainActor
protocol ObserveBookingUseCase {
    func execute(id: String) -> AnyPublisher<Booking?, Never>
}

// MARK: - ObserveBookingUseCaseImpl

@MainActor
final class ObserveBookingUseCaseImpl: ObserveBookingUseCase {

    private let repository: BookingsRepository

    init(repository: BookingsRepository) {
        self.repository = repository
    }

    func execute(id: String) -> AnyPublisher<Booking?, Never> {
        repository.observeBooking(id: id)
    }
}
