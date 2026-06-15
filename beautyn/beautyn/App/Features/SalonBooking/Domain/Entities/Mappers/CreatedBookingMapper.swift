import Foundation

// MARK: - CreatedBookingMapper
//
// Builds a rich `Booking` for the Booking Details screen shown right after the
// success splash. The bookings-list endpoint can't supply per-service
// descriptions / prices, so we assemble them here from the salon catalog plus
// the chosen slot and the create-booking response (which carries the manage
// link and the new booking id).

enum CreatedBookingMapper {

    static func make(
        salon: Salon,
        selectedServiceIds: Set<String>,
        datetime: String,
        created: CreatedBooking
    ) -> Booking {
        let services = salon.services
            .filter { selectedServiceIds.contains($0.id) }
            .sorted { ($0.sortOrder ?? .max) < ($1.sortOrder ?? .max) }

        let totalDuration = services.reduce(0) { $0 + $1.durationMinutes }
        let totalPrice = services.reduce(0) { $0 + $1.price }

        let timezone = Self.timeZone(fromISO: datetime)
        let start = Self.parseDate(datetime) ?? Date()
        let end = start.addingTimeInterval(TimeInterval(totalDuration * 60))

        return Booking(
            id: created.bookingId,
            salonId: salon.id,
            salonName: salon.name,
            salonAddress: salon.addressLine,
            salonImageURL: (salon.coverImageUrl ?? salon.imageUrls.first).flatMap(URL.init(string:)),
            // Salon carries no coordinate — the route action falls back to the address.
            coordinate: nil,
            bookingUrl: created.shortLink.flatMap(URL.init(string:)),
            status: BookingStatus(raw: created.status),
            datetime: start,
            endDatetime: end,
            services: services.map {
                BookingService(id: $0.id, name: $0.name, description: $0.description, price: $0.price)
            },
            // Salon catalog prices are already in UAH (unlike the list endpoint's cents).
            totalPrice: totalPrice,
            currency: services.first?.currency,
            durationMinutes: totalDuration,
            timezone: timezone
        )
    }

    // MARK: - Date parsing

    private static let isoWithFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoPlain: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static func parseDate(_ value: String) -> Date? {
        isoWithFraction.date(from: value) ?? isoPlain.date(from: value)
    }

    // Fixed-offset zone from the ISO string's trailing offset ("+03:00" / "Z"),
    // so the appointment renders in its booked local wall-clock regardless of the
    // device timezone (the Salon model carries no IANA zone).
    private static func timeZone(fromISO value: String) -> TimeZone? {
        if value.hasSuffix("Z") { return TimeZone(secondsFromGMT: 0) }
        guard value.count >= 6 else { return nil }
        let offset = value.suffix(6)            // e.g. "+03:00"
        guard let sign = offset.first, sign == "+" || sign == "-" else { return nil }
        let parts = offset.dropFirst().split(separator: ":")
        guard parts.count == 2, let hours = Int(parts[0]), let minutes = Int(parts[1]) else { return nil }
        let seconds = (hours * 3600 + minutes * 60) * (sign == "-" ? -1 : 1)
        return TimeZone(secondsFromGMT: seconds)
    }
}
