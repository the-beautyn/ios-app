import Foundation

// MARK: - ConfirmEasyweekBookingResponseDTO
//
// Response of `POST /bookings/easyweek/confirm`. We only need the local
// `booking_id` to fetch the full booking afterwards; the remaining fields
// (status / datetime / easyweek summary) are intentionally ignored here.

struct ConfirmEasyweekBookingResponseDTO: Decodable {
    let bookingId: String
    let status: String?

    enum CodingKeys: String, CodingKey {
        case bookingId = "booking_id"
        case status
    }
}
