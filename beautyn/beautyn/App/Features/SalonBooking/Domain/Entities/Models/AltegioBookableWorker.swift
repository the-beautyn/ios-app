import Foundation

// MARK: - AltegioBookableWorker
//
// Availability info for a salon worker in the in-app Altegio booking flow. We
// already hold the rich `SalonWorker` on device, so this only carries what the
// `/booking/altegio/{salonId}/workers` endpoint adds: whether the worker is
// bookable for the current filters and their next available slots. `id` matches
// `SalonWorker.id`.

struct AltegioBookableWorker: Identifiable {
    let id: String
    let isBookable: Bool
    let slots: [AltegioBookingSlot]
}

// MARK: - AltegioBookingSlot

struct AltegioBookingSlot {
    /// Time-of-day label for the pill, e.g. "08:00".
    let time: String
    /// Raw datetime from the API (ISO 8601). Carried verbatim into the booking
    /// flow so the value isn't lost to a Date round-trip.
    let datetime: String
    /// Parsed `datetime`, used only for the "dd.MM" nearest-date label. `nil`
    /// when the string can't be parsed.
    let date: Date?
    /// Service duration in seconds.
    let seanceLengthSec: Int
    /// Total duration incl. buffer/transition time in seconds.
    let sumLengthSec: Int
}
