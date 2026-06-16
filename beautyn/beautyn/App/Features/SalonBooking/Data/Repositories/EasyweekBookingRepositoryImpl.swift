import Foundation

// MARK: - EasyweekBookingRepositoryImpl

final class EasyweekBookingRepositoryImpl: EasyweekBookingRepository {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func confirm(salonId: String, bookingUuid: String) async throws -> String {
        let target = Target(type: EasyweekBookingTarget.confirm(salonId: salonId, bookingUuid: bookingUuid))
        let response: ConfirmEasyweekBookingResponseDTO = try await networkService.request(target)
        return response.bookingId
    }
}
