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
    /// Per-service breakdown (name + price) for the Booking Details screen.
    /// Empty when the feed carries only names — Booking Details then falls back
    /// to name-only rows (see `NextBookingMapper`).
    let services: [NextBookingService]
    /// Short link to view/manage the booking. Drives the Booking Details
    /// "Make Changes" action; `nil` when the feed didn't supply one.
    let bookingUrl: String?
    /// Salon's IANA timezone for rendering the appointment in salon-local time.
    /// `nil` falls back to the device timezone.
    let timezone: TimeZone?
}

// MARK: - NextBookingService

struct NextBookingService {
    let id: String
    let name: String
    let description: String?
    /// Price in minor units (cents/kopiykas); `NextBookingMapper` divides by 100.
    let priceCents: Int?
}
