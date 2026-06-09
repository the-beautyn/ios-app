import Foundation

// MARK: - GetMyBookingsUseCase

protocol GetMyBookingsUseCase {
    func execute(tab: BookingTab) async throws -> [Booking]
}

// MARK: - GetMyBookingsUseCaseImpl
//
// Maps each tab onto the backend `GET /v1/bookings` filters. The endpoint has
// no dedicated "upcoming/past" flag, so we derive it from `status` + the
// booking datetime:
//   • upcoming  → status=created, from=now, soonest-first
//   • past      → status=completed, most-recent-first
//   • cancelled → status=canceled, most-recent-first
// Only the first page is loaded (see `pageLimit`).

final class GetMyBookingsUseCaseImpl: GetMyBookingsUseCase {

    private let repository: MyBookingsRepository
    private let pageLimit: Int

    init(repository: MyBookingsRepository, pageLimit: Int = 50) {
        self.repository = repository
        self.pageLimit = pageLimit
    }

    func execute(tab: BookingTab) async throws -> [Booking] {
        let request: BookingsRequest
        switch tab {
        case .upcoming:
            request = BookingsRequest(
                status: BookingStatus.created.rawValue,
                from: Date(),
                to: nil,
                limit: pageLimit,
                sort: .datetimeAsc
            )
        case .past:
            request = BookingsRequest(
                status: BookingStatus.completed.rawValue,
                from: nil,
                to: nil,
                limit: pageLimit,
                sort: .datetimeDesc
            )
        case .cancelled:
            request = BookingsRequest(
                status: BookingStatus.canceled.rawValue,
                from: nil,
                to: nil,
                limit: pageLimit,
                sort: .datetimeDesc
            )
        }
        return try await repository.getBookings(request)
    }
}
