import Foundation

// MARK: - SyncBookingFromCrmUseCase
//
// Re-pulls a single booking's current state from its CRM (Altegio / EasyWeek)
// into the cache and returns it. This is the "Make changes" refresh variant the
// `RefreshBookingUseCase` doc anticipated: unlike a plain `refreshBooking` (DB
// read), it reflects edits / cancellations the user made in the CRM webview.

@MainActor
protocol SyncBookingFromCrmUseCase {
    @discardableResult
    func execute(id: String) async throws -> Booking
}

// MARK: - SyncBookingFromCrmUseCaseImpl

@MainActor
final class SyncBookingFromCrmUseCaseImpl: SyncBookingFromCrmUseCase {

    private let repository: BookingsRepository

    init(repository: BookingsRepository) {
        self.repository = repository
    }

    @discardableResult
    func execute(id: String) async throws -> Booking {
        try await repository.syncBookingFromCrm(id: id)
    }
}
