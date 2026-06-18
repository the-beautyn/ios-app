import Foundation

// MARK: - NextBookingMapper
//
// Converts the Home feed's `NextBooking` summary into the full `Booking` the
// Booking Details screen expects. The home feed has no coordinate, so that falls
// back gracefully; per-service prices come through `next.services` when the
// provider supplied a breakdown, otherwise we render name-only rows. The next
// appointment is always upcoming, so status is `.created` (the details screen
// still derives past/future from the datetime).

enum NextBookingMapper {

    static func makeBooking(_ next: NextBooking) -> Booking {
        Booking(
            id: next.bookingId,
            salonId: next.salonId,
            salonName: next.salonName,
            salonAddress: next.salonAddressLine,
            salonImageURL: next.salonCoverImageUrl.flatMap(URL.init(string:)),
            coordinate: nil,
            bookingUrl: next.bookingUrl.flatMap(URL.init(string:)),
            // The home feed doesn't carry the CRM type; Booking Details refreshes
            // the booking on appear to learn it before "Внести зміни" is tapped.
            crmType: .unknown,
            crmRecordId: nil,
            status: .created,
            datetime: next.datetime,
            endDatetime: next.endDatetime,
            // The next appointment is always upcoming, never cancelled.
            cancelledAt: nil,
            services: next.services.isEmpty
                ? next.serviceNames.map {
                    BookingService(id: $0, name: $0, description: nil, price: nil)
                }
                : next.services.map { service in
                    BookingService(
                        id: service.id,
                        name: service.name,
                        description: service.description,
                        // Home feed sends per-service price in cents — convert to UAH.
                        price: service.priceCents.map { Double($0) / 100 }
                    )
                },
            // Home feed sends the total in cents (kopiykas) — convert to UAH.
            totalPrice: next.totalPriceCents.map { Double($0) / 100 },
            currency: nil,
            durationMinutes: next.durationMinutes,
            timezone: next.timezone
        )
    }
}
