import Combine
import Foundation

// MARK: - BookingsRepositoryImpl
//
// Stateful source of truth: an in-memory `[id: Booking]` cache behind a
// `CurrentValueSubject`. Reads are reactive (subscribers get the current value
// immediately, then every change); fetches merge into the cache. Confined to the
// main actor — the cache feeds `@MainActor` view models, and all mutations happen
// here so the subject is never touched off-main.

@MainActor
final class BookingsRepositoryImpl: BookingsRepository {

    private let networkService: NetworkService
    private let pageLimit: Int
    private let cache = CurrentValueSubject<[String: Booking], Never>([:])
    private var cancellables = Set<AnyCancellable>()

    init(networkService: NetworkService, sessionManager: SessionManager, pageLimit: Int = 50) {
        self.networkService = networkService
        self.pageLimit = pageLimit
        // Clear the cache on logout / account switch so one account never sees
        // another's bookings.
        sessionManager.isAuthenticatedPublisher
            .filter { !$0 }
            .sink { [weak self] _ in self?.clear() }
            .store(in: &cancellables)
    }

    // MARK: - Reads

    func observeBookings() -> AnyPublisher<[Booking], Never> {
        cache
            .map { Array($0.values) }
            .eraseToAnyPublisher()
    }

    func observeBooking(id: String) -> AnyPublisher<Booking?, Never> {
        cache
            .map { $0[id] }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    // MARK: - Fetch

    func refreshBookings(_ category: BookingCategory?) async throws {
        let categories = category.map { [$0] } ?? BookingCategory.allCases
        for category in categories {
            merge(try await fetch(category))
        }
    }

    @discardableResult
    func refreshBooking(id: String) async throws -> Booking {
        try await fetchOne(BookingsTarget.getBookingById(id: id))
    }

    @discardableResult
    func syncBookingFromCrm(id: String) async throws -> Booking {
        try await fetchOne(BookingsTarget.refreshBookingFromCrm(id: id))
    }

    // MARK: - Writes

    func put(_ booking: Booking) {
        merge([booking])
    }

    func clear() {
        guard !cache.value.isEmpty else { return }
        cache.send([:])
    }

    // MARK: - Private

    /// Request a single booking from `target`, map it, cache it, and return it.
    /// Shared by `refreshBooking` (DB read) and `syncBookingFromCrm` (live CRM).
    private func fetchOne(_ targetType: BookingsTarget) async throws -> Booking {
        let target = Target(type: targetType)
        let dto: BookingItemDTO = try await networkService.request(target)
        guard let booking = BookingMapper.map(dto) else {
            throw MyBookingsError.bookingNotFound
        }
        put(booking)
        return booking
    }

    private func fetch(_ category: BookingCategory) async throws -> [Booking] {
        let target = Target(type: BookingsTarget.getBookings(
            status: category.status.rawValue,
            from: category.fromNow ? Self.isoString(Date()) : nil,
            to: nil,
            limit: pageLimit,
            cursor: nil,
            sort: category.sort.rawValue
        ))
        let response: BookingListResponseDTO = try await networkService.request(target)
        return BookingMapper.map(response.items)
    }

    /// Upsert-only merge (never prunes). Emits only when something actually
    /// changed so observers don't churn on no-op refreshes.
    private func merge(_ bookings: [Booking]) {
        var dict = cache.value
        var changed = false
        for booking in bookings where dict[booking.id] != booking {
            dict[booking.id] = booking
            changed = true
        }
        if changed { cache.send(dict) }
    }

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static func isoString(_ date: Date) -> String {
        isoFormatter.string(from: date)
    }
}
