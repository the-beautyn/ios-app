import Foundation

// MARK: - CreatedBooking
//
// Result of creating a booking record via
// `POST /booking/altegio/{salonId}/records`. `bookingId` is our local booking id;
// `crmRecordId` is Altegio's record id; `shortLink` is an optional online-booking
// link (currently always nil from the backend).

struct CreatedBooking {
    let bookingId: String
    let crmRecordId: Int
    let shortLink: String?
    let status: String
}
