import Foundation

// MARK: - EasyweekBookingRepository

protocol EasyweekBookingRepository {
    /// Confirm a completed EasyWeek widget booking on the backend. Returns our
    /// local booking id.
    func confirm(salonId: String, bookingUuid: String) async throws -> String
}
