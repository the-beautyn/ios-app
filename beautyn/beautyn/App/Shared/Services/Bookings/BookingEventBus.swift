import Combine
import Foundation

// MARK: - BookingCreatedEvent

struct BookingCreatedEvent: Equatable {
    let bookingId: String
    let salonId: String
}

// MARK: - BookingEventBus

protocol BookingEventBus {
    var bookingCreated: AnyPublisher<BookingCreatedEvent, Never> { get }
    func notifyBookingCreated(_ event: BookingCreatedEvent)
}

// MARK: - BookingEventBusImpl

final class BookingEventBusImpl: BookingEventBus {

    private let subject = PassthroughSubject<BookingCreatedEvent, Never>()

    var bookingCreated: AnyPublisher<BookingCreatedEvent, Never> {
        subject.eraseToAnyPublisher()
    }

    func notifyBookingCreated(_ event: BookingCreatedEvent) {
        subject.send(event)
    }
}
