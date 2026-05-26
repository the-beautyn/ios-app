import Foundation

// MARK: - SalonRepositoryImpl

final class SalonRepositoryImpl: SalonRepository {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getSalon(id: String) async throws -> Salon {
        let target = Target(type: SalonsTarget.getSalonById(id: id, include: SalonInclude.all))
        let response: SalonResponseDTO = try await networkService.request(target)
        return SalonMapper.map(response)
    }

    func getShare(id: String) async throws -> SalonShare {
        let target = Target(type: SalonsTarget.getShare(id: id))
        let response: SalonShareResponseDTO = try await networkService.request(target)
        return SalonMapper.mapShare(response)
    }
}
