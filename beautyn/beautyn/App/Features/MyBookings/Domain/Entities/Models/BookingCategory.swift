import Foundation

// MARK: - BookingCategory
//
// The canonical bucketing of bookings, shared by two places that must agree:
//   • the repository's `GET /bookings` status filter (server-side fetch), and
//   • the local split of the cached array into the My Bookings tabs.
// Keeping both off this one type prevents a booking from landing in two tabs or
// none. Mirrors the backend's `buildClientScopeWhere` (which derives past/upcoming
// from the datetime, not just the stored status).

enum BookingCategory: CaseIterable {
    case upcoming
    case past
    case cancelled

    /// Status filter sent to `GET /bookings` for this category.
    var status: BookingStatus {
        switch self {
        case .upcoming: return .created
        case .past: return .completed
        case .cancelled: return .canceled
        }
    }

    var sort: BookingsSort {
        switch self {
        case .upcoming: return .datetimeAsc
        case .past, .cancelled: return .datetimeDesc
        }
    }

    /// Upcoming is additionally constrained to `from = now` server-side.
    var fromNow: Bool { self == .upcoming }

    /// Display ordering for this category's list, mirroring the server ordering in
    /// `listForClient`: upcoming is soonest-first; past is most-recent appointment
    /// first; cancelled is most-recently-cancelled first (falling back to the
    /// appointment date for legacy rows without a cancellation timestamp).
    func sorted(_ bookings: [Booking]) -> [Booking] {
        switch self {
        case .upcoming:
            return bookings.sorted { $0.datetime < $1.datetime }
        case .past:
            return bookings.sorted { $0.datetime > $1.datetime }
        case .cancelled:
            return bookings.sorted { ($0.cancelledAt ?? $0.datetime) > ($1.cancelledAt ?? $1.datetime) }
        }
    }

    /// Does a cached booking belong in this category right now? Mirrors the server
    /// filter so a booking buckets the same whether it arrived via a category
    /// fetch or a single-booking refresh.
    func contains(_ booking: Booking, now: Date = Date()) -> Bool {
        switch self {
        case .upcoming:
            return booking.status == .created && booking.datetime >= now
        case .past:
            // The CRM rarely flips created→completed, so treat any non-cancelled
            // booking whose time has passed as past (same as BookingDetails.state).
            switch booking.status {
            case .completed: return true
            case .created, .unknown: return booking.datetime < now
            case .canceled, .deleted: return false
            }
        case .cancelled:
            return booking.status == .canceled || booking.status == .deleted
        }
    }
}
