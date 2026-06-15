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

// MARK: - BookingService

struct BookingService: Identifiable {
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
