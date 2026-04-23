import Foundation

// MARK: - TokenRefresher

actor TokenRefresher {

    private let useCase: RefreshTokenUseCase
    private var inFlight: Task<Void, Error>?

    init(useCase: RefreshTokenUseCase) {
        self.useCase = useCase
    }

    func refresh() async throws {
        if let inFlight {
            try await inFlight.value
            return
        }

        let task = Task { try await useCase.execute() }
        inFlight = task

        do {
            try await task.value
            inFlight = nil
        } catch {
            inFlight = nil
            throw error
        }
    }
}
