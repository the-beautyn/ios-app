import Foundation

// MARK: - AltegioBookingRepository

protocol AltegioBookingRepository {
    /// Ids of services the salon can book given the optional selection / worker
    /// filter. Empty filters → every Altegio-connected service.
    func availableServiceIds(
        salonId: String,
        selectedServiceIds: [String],
        workerId: String?
    ) async throws -> Set<String>
}
