import Foundation

// MARK: - MyBookingsRepository

protocol MyBookingsRepository {
    func getBookings(_ request: BookingsRequest) async throws -> [Booking]
    /// Fetch a single booking by its local id (`GET /bookings/{id}`).
    func getBooking(id: String) async throws -> Booking
}

// MARK: - MyBookingsError

enum MyBookingsError: Error {
    case bookingNotFound
}

// MARK: - BookingsRequest

struct BookingsRequest {
    let status: String?
    let from: Date?
    let to: Date?
    let limit: Int
    let sort: BookingsSort?
}

// MARK: - BookingsSort

enum BookingsSort: String {
    case datetimeAsc = "datetime_asc"
    case datetimeDesc = "datetime_desc"
}
