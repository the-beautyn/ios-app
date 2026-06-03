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
}
