import Foundation

// MARK: - AltegioTimeSlotsResponseDTO
//
// Response of `/booking/altegio/{salonId}/timeslots`: the available time slots
// for a single day. Each slot reuses `AltegioBookingSlotDTO`, the same shape the
// workers endpoint returns under `includeSlots`.

struct AltegioTimeSlotsResponseDTO: Decodable {
    let slots: [AltegioBookingSlotDTO]
}
