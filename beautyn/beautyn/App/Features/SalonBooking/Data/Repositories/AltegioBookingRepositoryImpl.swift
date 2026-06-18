import Foundation

// MARK: - AltegioBookingRepositoryImpl

final class AltegioBookingRepositoryImpl: AltegioBookingRepository {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func availableServiceIds(
        salonId: String,
        selectedServiceIds: [String],
        workerId: String?,
        datetime: String?
    ) async throws -> Set<String> {
        let target = Target(type: AltegioBookingTarget.getBookableServices(
            salonId: salonId,
            selectedServiceIds: selectedServiceIds,
            workerId: workerId,
            datetime: datetime
        ))
        let response: AltegioBookableServicesResponseDTO = try await networkService.request(target)
        return AltegioBookingMapper.availableServiceIds(response)
    }

    func availableWorkers(
        salonId: String,
        serviceIds: [String],
        datetime: String?,
        includeSlots: Bool
    ) async throws -> [AltegioBookableWorker] {
        let target = Target(type: AltegioBookingTarget.getBookableWorkers(
            salonId: salonId,
            serviceIds: serviceIds,
            datetime: datetime,
            includeSlots: includeSlots
        ))
        let response: AltegioBookableWorkersResponseDTO = try await networkService.request(target)
        return AltegioBookingMapper.bookableWorkers(response)
    }

    func availableDates(
        salonId: String,
        serviceIds: [String],
        workerId: String?,
        dateFrom: String,
        dateTo: String
    ) async throws -> [Date] {
        let target = Target(type: AltegioBookingTarget.getBookableDates(
            salonId: salonId,
            serviceIds: serviceIds,
            workerId: workerId,
            dateFrom: dateFrom,
            dateTo: dateTo
        ))
        let response: AltegioBookableDatesResponseDTO = try await networkService.request(target)
        return AltegioBookingMapper.bookingDates(response)
    }

    func timeSlots(
        salonId: String,
        date: String,
        workerId: String?,
        serviceIds: [String]
    ) async throws -> [AltegioBookingSlot] {
        let target = Target(type: AltegioBookingTarget.getTimeSlots(
            salonId: salonId,
            date: date,
            workerId: workerId,
            serviceIds: serviceIds
        ))
        let response: AltegioTimeSlotsResponseDTO = try await networkService.request(target)
        return AltegioBookingMapper.timeSlots(response)
    }

    func createBooking(
        salonId: String,
        workerId: String?,
        serviceIds: [String],
        datetime: String,
        comment: String?
    ) async throws -> CreatedBooking {
        let target = Target(type: AltegioBookingTarget.createRecord(
            salonId: salonId,
            workerId: workerId,
            serviceIds: serviceIds,
            datetime: datetime,
            comment: comment
        ))
        let response: AltegioCreateRecordResponseDTO = try await networkService.request(target)
        return AltegioBookingMapper.createdBooking(response)
    }
}
