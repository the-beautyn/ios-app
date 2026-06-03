import Foundation

// MARK: - AltegioBookingMapper

enum AltegioBookingMapper {

    /// The response lists every active salon service with an `is_available`
    /// flag. On device we already hold the rich `Salon` data, so we only need
    /// the set of ids that are currently bookable to filter what we show.
    static func availableServiceIds(_ dto: AltegioBookableServicesResponseDTO) -> Set<String> {
        Set(dto.services.filter { $0.isAvailable }.map { $0.id })
    }

    /// Maps worker availability + slots. As with services, we already hold the
    /// rich `SalonWorker` on device, so each `AltegioBookableWorker` carries only
    /// the bookable flag and (when requested) the next slots, keyed by id.
    static func bookableWorkers(_ dto: AltegioBookableWorkersResponseDTO) -> [AltegioBookableWorker] {
        dto.workers.map { worker in
            AltegioBookableWorker(
                id: worker.id,
                isBookable: worker.bookable,
                slots: (worker.slots ?? []).map { slot in
                    AltegioBookingSlot(
                        time: slot.time,
                        datetime: slot.datetime,
                        date: parseSlotDate(slot.datetime),
                        seanceLengthSec: slot.seanceLengthSec,
                        sumLengthSec: slot.sumLengthSec
                    )
                }
            )
        }
    }

    // MARK: - Date parsing

    // Altegio slot datetimes come ISO 8601 with an offset (e.g.
    // "2025-01-01T10:00:00+03:00"). Parse defensively across the common shapes
    // so the nearest-date label survives format drift; only used for display.
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let isoFractionalFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let plainFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    private static func parseSlotDate(_ string: String) -> Date? {
        isoFormatter.date(from: string)
            ?? isoFractionalFormatter.date(from: string)
            ?? plainFormatter.date(from: string)
    }
}
