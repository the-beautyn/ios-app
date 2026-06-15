import Foundation
import CoreLocation

// MARK: - BookingMapper

enum BookingMapper {

    static func map(_ items: [BookingItemDTO]) -> [Booking] {
        items.compactMap { map($0) }
    }

    static func map(_ dto: BookingItemDTO) -> Booking? {
        guard let datetime = parseDate(dto.datetime) else { return nil }

        let coordinate: CLLocationCoordinate2D?
        if let latitude = dto.salon?.latitude, let longitude = dto.salon?.longitude {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            coordinate = nil
        }

        return Booking(
            id: dto.id,
            salonId: dto.salonId,
            salonName: dto.salon?.name ?? "",
            salonAddress: dto.salon?.addressLine,
            salonImageURL: dto.salon?.coverImageUrl.flatMap(URL.init(string:)),
            coordinate: coordinate,
            bookingUrl: dto.shortLink.flatMap(URL.init(string:)),
            status: BookingStatus(raw: dto.status),
            datetime: datetime,
            endDatetime: dto.endDatetime.flatMap { parseDate($0) },
            services: mapServices(dto),
            // Backend sends the total in cents (kopiykas); convert to UAH so the
            // card shows e.g. 300, not 30000 — same as SalonMapper / the Home feed.
            totalPrice: dto.totalPrice.map { $0 / 100 },
            currency: dto.currency,
            durationMinutes: dto.durationMinutes,
            timezone: dto.salon?.timezone.flatMap(TimeZone.init(identifier:))
        )
    }

    // MARK: - Services

    // Per-service price/description live under the provider block; the flat
    // `service_names` is the name-only fallback. Prices arrive in cents (same
    // unit as `total_price`), so convert to UAH — matching the total above.
    private static func mapServices(_ dto: BookingItemDTO) -> [BookingService] {
        if let easyweek = dto.providerSpecific?.easyweek?.orderedServices, !easyweek.isEmpty {
            return easyweek.map { service in
                BookingService(
                    id: service.externalUuid ?? service.name ?? UUID().uuidString,
                    name: service.name ?? "",
                    description: service.description,
                    price: service.price.map { $0 / 100 }
                )
            }
        }

        if let altegio = dto.providerSpecific?.altegio?.services, !altegio.isEmpty {
            return altegio.map { service in
                BookingService(
                    id: service.externalId ?? service.title ?? UUID().uuidString,
                    name: service.title ?? "",
                    description: nil,
                    price: (service.costToPay ?? service.cost).map { $0 / 100 }
                )
            }
        }

        // No provider breakdown — fall back to names only.
        return (dto.serviceNames ?? []).map {
            BookingService(id: $0, name: $0, description: nil, price: nil)
        }
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
}
