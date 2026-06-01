import Foundation

// MARK: - AltegioBookingMapper

enum AltegioBookingMapper {

    /// The response lists every active salon service with an `is_available`
    /// flag. On device we already hold the rich `Salon` data, so we only need
    /// the set of ids that are currently bookable to filter what we show.
    static func availableServiceIds(_ dto: AltegioBookableServicesResponseDTO) -> Set<String> {
        Set(dto.services.filter { $0.isAvailable }.map { $0.id })
    }
}
