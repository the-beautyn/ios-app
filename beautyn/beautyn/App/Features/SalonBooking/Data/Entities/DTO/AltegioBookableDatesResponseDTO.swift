import Foundation

// MARK: - AltegioBookableDatesResponseDTO
//
// Response of `/booking/altegio/{salonId}/dates`: the bookable calendar days for
// the requested range, each a plain `yyyy-MM-dd` string.

struct AltegioBookableDatesResponseDTO: Decodable {
    let bookingDates: [String]
}
