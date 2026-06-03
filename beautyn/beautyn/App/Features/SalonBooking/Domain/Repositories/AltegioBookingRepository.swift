import Foundation

// MARK: - AltegioBookingRepository

protocol AltegioBookingRepository {
    /// Ids of services the salon can book given the optional selection / worker /
    /// datetime filter. Empty filters → every Altegio-connected service.
    func availableServiceIds(
        salonId: String,
        selectedServiceIds: [String],
        workerId: String?,
        datetime: String?
    ) async throws -> Set<String>

    /// Workers the salon can book given the optional service / datetime filter,
    /// each flagged `isBookable` and (when `includeSlots`) carrying their next
    /// available slots. Empty filters → every Altegio-connected worker.
    func availableWorkers(
        salonId: String,
        serviceIds: [String],
        datetime: String?,
        includeSlots: Bool
    ) async throws -> [AltegioBookableWorker]
}
