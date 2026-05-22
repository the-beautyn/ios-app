import Foundation

// MARK: - SaveSalonUseCase

protocol SaveSalonUseCase {
    func execute(salonId: String) async throws
}

// MARK: - SaveSalonUseCaseImpl

final class SaveSalonUseCaseImpl: SaveSalonUseCase {

    private let repository: SavedSalonsRepository
    private let eventBus: any SavedSalonsEventBus

    init(repository: SavedSalonsRepository, eventBus: any SavedSalonsEventBus) {
        self.repository = repository
        self.eventBus = eventBus
    }

    func execute(salonId: String) async throws {
        try await repository.save(salonId: salonId)
        eventBus.notify(SavedSalonChange(salonId: salonId, isSaved: true))
    }
}
