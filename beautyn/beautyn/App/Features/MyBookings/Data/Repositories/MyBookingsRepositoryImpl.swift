import Foundation

// MARK: - MyBookingsRepositoryImpl

final class MyBookingsRepositoryImpl: MyBookingsRepository {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getBookings(_ request: BookingsRequest) async throws -> [Booking] {
        let target = Target(type: BookingsTarget.getBookings(
            status: request.status,
            from: request.from.map(Self.isoString),
            to: request.to.map(Self.isoString),
            limit: request.limit,
            cursor: nil,
            sort: request.sort?.rawValue
        ))
        let response: BookingListResponseDTO = try await networkService.request(target)
        return BookingMapper.map(response.items)
    }

    func getBooking(id: String) async throws -> Booking {
        let target = Target(type: BookingsTarget.getBookingById(id: id))
        let dto: BookingItemDTO = try await networkService.request(target)
        guard let booking = BookingMapper.map(dto) else {
            throw MyBookingsError.bookingNotFound
        }
        return booking
    }

    // MARK: - Private

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static func isoString(_ date: Date) -> String {
        isoFormatter.string(from: date)
    }
}
