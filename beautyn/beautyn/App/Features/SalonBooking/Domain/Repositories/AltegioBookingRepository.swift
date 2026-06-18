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

    /// Bookable calendar days in `[dateFrom, dateTo]` (both `yyyy-MM-dd`), each
    /// the start of a day. `serviceIds` / `workerId` narrow availability.
    func availableDates(
        salonId: String,
        serviceIds: [String],
        workerId: String?,
        dateFrom: String,
        dateTo: String
    ) async throws -> [Date]

    /// Available time slots for `date` (`yyyy-MM-dd`). `serviceIds` / `workerId`
    /// narrow availability.
    func timeSlots(
        salonId: String,
        date: String,
        workerId: String?,
        serviceIds: [String]
    ) async throws -> [AltegioBookingSlot]

    /// Create the booking record. `workerId` nil = "any team member".
    func createBooking(
        salonId: String,
        workerId: String?,
        serviceIds: [String],
        datetime: String,
        comment: String?
    ) async throws -> CreatedBooking
}
