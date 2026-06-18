import Combine
import Foundation

// MARK: - BookingsRepository
//
// The single source of truth for bookings. It owns an in-memory cache and is the
// only place that talks to the network for bookings. Screens never touch it
// directly — they read through observer use cases and trigger fetches through
// refresh use cases (see the `Observe*`/`Refresh*` use cases). Registered as an
// app-wide singleton so every feature shares one cache.

@MainActor
protocol BookingsRepository {
    /// Reactive snapshot of every cached booking. Emits the current value on
    /// subscribe and again whenever the cache changes.
    func observeBookings() -> AnyPublisher<[Booking], Never>

    /// Reactive view of a single booking — `nil` until it's cached / after removal.
    func observeBooking(id: String) -> AnyPublisher<Booking?, Never>

    /// Fetch a category from the backend (nil = all categories) and merge the
    /// results into the cache.
    func refreshBookings(_ category: BookingCategory?) async throws

    /// Fetch one booking by its local id, cache it, and return it.
    @discardableResult
    func refreshBooking(id: String) async throws -> Booking

    /// Re-pull one booking's current state from its CRM (Altegio / EasyWeek),
    /// cache it, and return it. Used when the "Внести зміни" webview closes — it
    /// reflects edits/cancellations made there that a plain DB read wouldn't see.
    @discardableResult
    func syncBookingFromCrm(id: String) async throws -> Booking

    /// Insert/replace a booking obtained elsewhere (the create / confirm flows
    /// already hold the full booking).
    func put(_ booking: Booking)

    /// Drop all cached bookings — called on logout / account switch.
    func clear()
}

// MARK: - MyBookingsError

enum MyBookingsError: Error {
    case bookingNotFound
}

// MARK: - BookingsSort

enum BookingsSort: String {
    case datetimeAsc = "datetime_asc"
    case datetimeDesc = "datetime_desc"
}
