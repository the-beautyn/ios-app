import Foundation

// MARK: - NextBooking

struct NextBooking {
    let bookingId: String
    let salonId: String
    let salonName: String
    let salonCoverImageUrl: String?
    let salonAddressLine: String?
    let datetime: Date
    let endDatetime: Date?
    let totalPriceCents: Int?
    let durationMinutes: Int?
    let serviceNames: [String]
    /// Salon's IANA timezone for rendering the appointment in salon-local time.
    /// `nil` falls back to the device timezone.
    let timezone: TimeZone?
}
