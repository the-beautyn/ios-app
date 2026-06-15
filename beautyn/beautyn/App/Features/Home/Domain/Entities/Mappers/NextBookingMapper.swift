import Foundation

// MARK: - NextBookingMapper
//
// Converts the Home feed's `NextBooking` summary into the full `Booking` the
// Booking Details screen expects. The home feed carries names only (no
// per-service price/description) and no coordinate or manage-link, so those fall
// back gracefully. The next appointment is always upcoming, so status is
// `.created` (the details screen still derives past/future from the datetime).

enum NextBookingMapper {

    static func makeBooking(_ next: NextBooking) -> Booking {
        Booking(
            id: next.bookingId,
            salonId: next.salonId,
            salonName: next.salonName,
            salonAddress: next.salonAddressLine,
            salonImageURL: next.salonCoverImageUrl.flatMap(URL.init(string:)),
            coordinate: nil,
            bookingUrl: nil,
            status: .created,
            datetime: next.datetime,
            endDatetime: next.endDatetime,
            services: next.serviceNames.map {
                BookingService(id: $0, name: $0, description: nil, price: nil)
            },
            // Home feed sends the total in cents (kopiykas) — convert to UAH.
            totalPrice: next.totalPriceCents.map { Double($0) / 100 },
            currency: nil,
            durationMinutes: next.durationMinutes,
            timezone: next.timezone
        )
    }
}
