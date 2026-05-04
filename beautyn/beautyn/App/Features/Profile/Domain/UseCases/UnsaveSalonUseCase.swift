import Foundation

// MARK: - UnsaveSalonUseCase

protocol UnsaveSalonUseCase {
    func execute(salonId: String) async throws
}

// MARK: - UnsaveSalonUseCaseImpl

final class UnsaveSalonUseCaseImpl: UnsaveSalonUseCase {

    private let repository: SavedSalonsRepository
    private let eventBus: any SavedSalonsEventBus

    init(repository: SavedSalonsRepository, eventBus: any SavedSalonsEventBus) {
        self.repository = repository
        self.eventBus = eventBus
    }

    func execute(salonId: String) async throws {
        try await repository.unsave(salonId: salonId)
        eventBus.notify(SavedSalonChange(salonId: salonId, isSaved: false))
    }
}
