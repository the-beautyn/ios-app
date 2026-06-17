import Foundation
import CoreLocation

// MARK: - Booking

struct Booking: Identifiable {
    let id: String
    let salonId: String
    let salonName: String
    let salonAddress: String?
    let salonImageURL: URL?
    let coordinate: CLLocationCoordinate2D?
    /// Short public link to manage the booking (reschedule / edit / cancel).
    /// Opened in the in-app WebView from "Внести зміни". Named to match
    /// `Salon.bookingUrl`. `nil` when the backend hasn't provided one yet.
    let bookingUrl: URL?
    let status: BookingStatus
    let datetime: Date
    let endDatetime: Date?
    /// When the booking was cancelled (server `cancelled_at`). Drives the Cancelled
    /// tab's ordering — most-recently-cancelled first. `nil` for active bookings and
    /// for legacy cancelled rows that predate the field (those fall back to `datetime`).
    let cancelledAt: Date?
    let services: [BookingService]
    let totalPrice: Double?
    let currency: String?
    let durationMinutes: Int?
    /// Salon's IANA timezone for rendering the appointment in salon-local time.
    /// `nil` falls back to the device timezone.
    let timezone: TimeZone?

    /// Service display names — kept for the appointment cards (Home / My Bookings list).
    var serviceNames: [String] { services.map(\.name) }
}

// MARK: - Booking + Equatable
//
// `CLLocationCoordinate2D` isn't `Equatable`, so we can't synthesize it — compare
// the coordinate by lat/long. Equatable lets the bookings cache de-duplicate
// (`removeDuplicates`) and avoids redundant `objectWillChange` on no-op upserts.

extension Booking: Equatable {
    static func == (lhs: Booking, rhs: Booking) -> Bool {
        lhs.id == rhs.id
            && lhs.salonId == rhs.salonId
            && lhs.salonName == rhs.salonName
            && lhs.salonAddress == rhs.salonAddress
            && lhs.salonImageURL == rhs.salonImageURL
            && lhs.coordinate?.latitude == rhs.coordinate?.latitude
            && lhs.coordinate?.longitude == rhs.coordinate?.longitude
            && lhs.bookingUrl == rhs.bookingUrl
            && lhs.status == rhs.status
            && lhs.datetime == rhs.datetime
            && lhs.endDatetime == rhs.endDatetime
            && lhs.cancelledAt == rhs.cancelledAt
            && lhs.services == rhs.services
            && lhs.totalPrice == rhs.totalPrice
            && lhs.currency == rhs.currency
            && lhs.durationMinutes == rhs.durationMinutes
            && lhs.timezone == rhs.timezone
    }
}

// MARK: - BookingService

struct BookingService: Identifiable, Equatable {
    let id: String
    let name: String
    /// Only available for bookings built from the salon catalog (post-success);
    /// the bookings-list endpoint provides names only.
    let description: String?
    let price: Double?
}

// MARK: - BookingStatus

enum BookingStatus: String {
    case created
    case completed
    case canceled
    case deleted
    case unknown

    init(raw: String) {
        self = BookingStatus(rawValue: raw) ?? .unknown
    }
}
