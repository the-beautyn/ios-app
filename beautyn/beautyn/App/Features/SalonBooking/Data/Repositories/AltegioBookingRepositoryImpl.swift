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
        workerId: String?
    ) async throws -> Set<String> {
        let target = Target(type: AltegioBookingTarget.getBookableServices(
            salonId: salonId,
            selectedServiceIds: selectedServiceIds,
            workerId: workerId
        ))
        let response: AltegioBookableServicesResponseDTO = try await networkService.request(target)
        return AltegioBookingMapper.availableServiceIds(response)
    }
}
