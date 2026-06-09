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
    let status: BookingStatus
    let datetime: Date
    let endDatetime: Date?
    let serviceNames: [String]
    let totalPrice: Double?
    let currency: String?
    let durationMinutes: Int?
    /// Salon's IANA timezone for rendering the appointment in salon-local time.
    /// `nil` falls back to the device timezone.
    let timezone: TimeZone?
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
