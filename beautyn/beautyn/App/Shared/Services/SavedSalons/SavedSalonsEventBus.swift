import Combine
import Foundation

// MARK: - SavedSalonChange

struct SavedSalonChange: Equatable {
    let salonId: String
    let isSaved: Bool
}

// MARK: - SavedSalonsEventBus

protocol SavedSalonsEventBus {
    var changes: AnyPublisher<SavedSalonChange, Never> { get }
    func notify(_ change: SavedSalonChange)
}

// MARK: - SavedSalonsEventBusImpl

final class SavedSalonsEventBusImpl: SavedSalonsEventBus {

    private let subject = PassthroughSubject<SavedSalonChange, Never>()

    var changes: AnyPublisher<SavedSalonChange, Never> {
        subject.eraseToAnyPublisher()
    }

    func notify(_ change: SavedSalonChange) {
        subject.send(change)
    }
}
