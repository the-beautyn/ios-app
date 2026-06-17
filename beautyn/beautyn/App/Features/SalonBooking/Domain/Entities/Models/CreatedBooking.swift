import Foundation

// MARK: - CreatedBooking
//
// Result of creating a booking record via
// `POST /booking/altegio/{salonId}/records`. `bookingId` is our local booking id;
// `crmRecordId` is Altegio's record id; `shortLink` is an optional online-booking
// link — the backend reads the new record back from Altegio at create and returns
// its `short_link` (nil only when that read-back wasn't available yet; a later sync
// then backfills it).

struct CreatedBooking {
    let bookingId: String
    let crmRecordId: Int
    let shortLink: String?
    let status: String
}
