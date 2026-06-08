import Foundation

// MARK: - AltegioCreateRecordResponseDTO
//
// Response of `POST /booking/altegio/{salonId}/records` (the `{ success, data }`
// envelope is stripped by NetworkService, so this decodes the inner object).

struct AltegioCreateRecordResponseDTO: Decodable {
    let bookingId: String
    let crmRecordId: Int
    let shortLink: String?
    let status: String

    enum CodingKeys: String, CodingKey {
        case bookingId = "booking_id"
        case crmRecordId = "crm_record_id"
        case shortLink = "short_link"
        case status
    }
}
