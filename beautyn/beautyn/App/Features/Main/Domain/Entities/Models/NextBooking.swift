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
}
