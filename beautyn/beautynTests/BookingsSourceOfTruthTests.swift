import XCTest
import Combine
@testable import beautyn

// MARK: - BookingsRepositoryTests
//
// The repository is the single source of truth: an in-memory cache with reactive
// reads. These cover the cache behaviour that the network paths build on
// (put/merge/observe/clear) plus the logout wiring.

@MainActor
final class BookingsRepositoryTests: XCTestCase {

    // Retain objects + subscriptions for the test's lifetime: these @MainActor
    // types (SessionManager + repo) hit a dealloc-timing crash under Xcode 26 if
    // released mid-test (same reason ViewRenderer retains its windows).
    private var retained: [AnyObject] = []

    override func tearDown() {
        retained.removeAll()
        super.tearDown()
    }

    private func makeRepository() -> (BookingsRepositoryImpl, SessionManager) {
        let storage = InMemoryStorage()
        let session = SessionManager(keychainService: storage, defaultsService: storage)
        let repo = BookingsRepositoryImpl(networkService: ThrowingNetworkService(), sessionManager: session)
        retained.append(session)
        retained.append(repo)
        return (repo, session)
    }

    func testPutThenObserveBookingEmitsIt() {
        let (repo, _) = makeRepository()
        let booking = makeBooking(id: "b1")

        repo.put(booking)

        XCTAssertEqual(currentBooking(repo, id: "b1"), booking)
        XCTAssertEqual(currentBookings(repo).map(\.id), ["b1"])
    }

    func testObserveBookingDedupesEqualValues() {
        let (repo, _) = makeRepository()
        var emissions: [Booking?] = []
        let cancellable = repo.observeBooking(id: "b1").sink { emissions.append($0) }
        retained.append(cancellable)

        repo.put(makeBooking(id: "b1", status: .created))   // change
        repo.put(makeBooking(id: "b1", status: .created))   // identical → no emit
        repo.put(makeBooking(id: "b1", status: .canceled))  // change

        // initial nil + two distinct values (the identical put is suppressed).
        XCTAssertEqual(emissions.count, 3)
        XCTAssertNil(emissions[0])
        XCTAssertEqual(emissions[1]?.status, .created)
        XCTAssertEqual(emissions[2]?.status, .canceled)
    }

    func testClearEmptiesTheCache() {
        let (repo, _) = makeRepository()
        repo.put(makeBooking(id: "b1"))
        repo.put(makeBooking(id: "b2"))

        repo.clear()

        XCTAssertTrue(currentBookings(repo).isEmpty)
        XCTAssertNil(currentBooking(repo, id: "b1"))
    }

    func testLogoutClearsTheCache() {
        let (repo, session) = makeRepository()

        // Authenticate (→ isAuthenticated true) so the subsequent logout actually
        // transitions false and emits (the publisher de-dupes repeated values).
        session.saveSession(accessToken: "a", refreshToken: "r", phoneVerificationRequired: false)
        repo.put(makeBooking(id: "b1"))
        XCTAssertNotNil(currentBooking(repo, id: "b1"))

        session.clearSession()

        XCTAssertNil(currentBooking(repo, id: "b1"))
    }

    // Grab the current (synchronous, seeded) value, retaining the subscription.
    private func currentBooking(_ repo: BookingsRepositoryImpl, id: String) -> Booking? {
        var value: Booking?
        let cancellable = repo.observeBooking(id: id).sink { value = $0 }
        retained.append(cancellable)
        return value
    }

    private func currentBookings(_ repo: BookingsRepositoryImpl) -> [Booking] {
        var value: [Booking] = []
        let cancellable = repo.observeBookings().sink { value = $0 }
        retained.append(cancellable)
        return value
    }
}

// MARK: - BookingCategoryTests
//
// The canonical bucketing must mirror the backend filter so a booking lands in
// exactly one tab (or none) — never two.

final class BookingCategoryTests: XCTestCase {

    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    func testUpcomingIsCreatedAndFuture() {
        let future = makeBooking(id: "1", status: .created, datetime: now.addingTimeInterval(3600))
        let past = makeBooking(id: "2", status: .created, datetime: now.addingTimeInterval(-3600))

        XCTAssertTrue(BookingCategory.upcoming.contains(future, now: now))
        XCTAssertFalse(BookingCategory.upcoming.contains(past, now: now))
    }

    func testPastIsCompletedOrElapsedNonCancelled() {
        let completed = makeBooking(id: "1", status: .completed, datetime: now.addingTimeInterval(-3600))
        let elapsedCreated = makeBooking(id: "2", status: .created, datetime: now.addingTimeInterval(-3600))
        let upcomingCreated = makeBooking(id: "3", status: .created, datetime: now.addingTimeInterval(3600))

        XCTAssertTrue(BookingCategory.past.contains(completed, now: now))
        XCTAssertTrue(BookingCategory.past.contains(elapsedCreated, now: now))
        XCTAssertFalse(BookingCategory.past.contains(upcomingCreated, now: now))
    }

    func testCancelledIsCanceledOrDeleted() {
        XCTAssertTrue(BookingCategory.cancelled.contains(makeBooking(id: "1", status: .canceled), now: now))
        XCTAssertTrue(BookingCategory.cancelled.contains(makeBooking(id: "2", status: .deleted), now: now))
        XCTAssertFalse(BookingCategory.cancelled.contains(makeBooking(id: "3", status: .created), now: now))
    }

    func testEachBookingFallsInAtMostOneCategory() {
        let samples = [
            makeBooking(id: "1", status: .created, datetime: now.addingTimeInterval(3600)),
            makeBooking(id: "2", status: .created, datetime: now.addingTimeInterval(-3600)),
            makeBooking(id: "3", status: .completed, datetime: now.addingTimeInterval(-3600)),
            makeBooking(id: "4", status: .canceled, datetime: now.addingTimeInterval(3600)),
            makeBooking(id: "5", status: .deleted, datetime: now.addingTimeInterval(-3600)),
        ]
        for booking in samples {
            let hits = BookingCategory.allCases.filter { $0.contains(booking, now: now) }
            XCTAssertLessThanOrEqual(hits.count, 1, "booking \(booking.id) matched \(hits)")
        }
    }
}

// MARK: - BookingMapperCrmTypeTests
//
// The "Внести зміни" flow branches on `Booking.crmType`, so the mapper must carry
// `crm_type` through from the backend (and default to `.unknown` when absent).

@MainActor
final class BookingMapperCrmTypeTests: XCTestCase {

    // `@MainActor` because the module's default isolation makes BookingItemDTO's
    // Decodable conformance main-actor-isolated (a Swift 6 error from a nonisolated
    // context).
    private func decode(_ json: String) throws -> BookingItemDTO {
        try JSONDecoder().decode(BookingItemDTO.self, from: Data(json.utf8))
    }

    func testMapsEasyweekCrmType() throws {
        let dto = try decode(#"{"id":"b1","salon_id":"s1","status":"created","datetime":"2026-01-01T10:00:00Z","crm_type":"EASYWEEK"}"#)
        XCTAssertEqual(BookingMapper.map(dto)?.crmType, .easyweek)
    }

    func testMapsAltegioCrmType() throws {
        let dto = try decode(#"{"id":"b2","salon_id":"s1","status":"created","datetime":"2026-01-01T10:00:00Z","crm_type":"ALTEGIO"}"#)
        XCTAssertEqual(BookingMapper.map(dto)?.crmType, .altegio)
    }

    func testMissingCrmTypeMapsToUnknown() throws {
        let dto = try decode(#"{"id":"b3","salon_id":"s1","status":"created","datetime":"2026-01-01T10:00:00Z"}"#)
        XCTAssertEqual(BookingMapper.map(dto)?.crmType, .unknown)
    }

    func testMapsCrmRecordId() throws {
        let dto = try decode(#"{"id":"b4","salon_id":"s1","status":"created","datetime":"2026-01-01T10:00:00Z","crm_record_id":"ew-uuid-123"}"#)
        XCTAssertEqual(BookingMapper.map(dto)?.crmRecordId, "ew-uuid-123")
    }

    func testMissingCrmRecordIdIsNil() throws {
        let dto = try decode(#"{"id":"b5","salon_id":"s1","status":"created","datetime":"2026-01-01T10:00:00Z"}"#)
        XCTAssertNil(BookingMapper.map(dto)?.crmRecordId)
    }
}

// MARK: - Test doubles

@MainActor
final class MockBookingsRepository: BookingsRepository {
    var stored: [String: Booking] = [:]
    var refreshBookingResult: Booking?
    var syncBookingResult: Booking?
    private(set) var refreshedId: String?
    private(set) var syncedId: String?
    private(set) var refreshedCategories: [BookingCategory?] = []
    private(set) var putBookings: [Booking] = []

    func observeBookings() -> AnyPublisher<[Booking], Never> {
        Just(Array(stored.values)).eraseToAnyPublisher()
    }

    func observeBooking(id: String) -> AnyPublisher<Booking?, Never> {
        Just(stored[id]).eraseToAnyPublisher()
    }

    func refreshBookings(_ category: BookingCategory?) async throws {
        refreshedCategories.append(category)
    }

    @discardableResult
    func refreshBooking(id: String) async throws -> Booking {
        refreshedId = id
        guard let booking = refreshBookingResult else { throw MyBookingsError.bookingNotFound }
        stored[id] = booking
        return booking
    }

    @discardableResult
    func syncBookingFromCrm(id: String) async throws -> Booking {
        syncedId = id
        guard let booking = syncBookingResult ?? refreshBookingResult else {
            throw MyBookingsError.bookingNotFound
        }
        stored[id] = booking
        return booking
    }

    func put(_ booking: Booking) {
        putBookings.append(booking)
        stored[booking.id] = booking
    }

    func clear() { stored.removeAll() }
}

private final class ThrowingNetworkService: NetworkService {
    enum Failure: Error { case notStubbed }
    func request<D: Decodable>(_ target: Target, priority: TaskPriority?) async throws -> D {
        throw Failure.notStubbed
    }
    func request(_ target: Target, priority: TaskPriority?) async throws {
        throw Failure.notStubbed
    }
}

/// In-memory `StorageService` / `KeychainService` so SessionManager has no real
/// keychain/defaults side effects in tests.
private final class InMemoryStorage: KeychainService {
    private var values: [String: Any] = [:]
    func retrieveValue<T: Codable>(for key: String) -> T? { values[key] as? T }
    func storeValue<T: Codable>(_ value: T, for key: String) { values[key] = value }
    func removeValue(for key: String) { values[key] = nil }
    func clearAll() { values.removeAll() }
}

// MARK: - BookingCategoryOrderingTests

final class BookingCategoryOrderingTests: XCTestCase {

    // The Cancelled tab orders by *when each booking was cancelled* (most recent
    // first), NOT by the appointment date — so a later appointment cancelled long
    // ago sorts below an earlier appointment cancelled just now.
    func testCancelledSortsByCancellationDateNotAppointmentDate() {
        let cancelledLongAgo = makeBooking(
            id: "appt-later",
            status: .canceled,
            datetime: Date(timeIntervalSince1970: 2_000), // later appointment
            cancelledAt: Date(timeIntervalSince1970: 100) // cancelled long ago
        )
        let cancelledRecently = makeBooking(
            id: "cancelled-latest",
            status: .canceled,
            datetime: Date(timeIntervalSince1970: 1_000), // earlier appointment
            cancelledAt: Date(timeIntervalSince1970: 900) // cancelled most recently
        )

        let sorted = BookingCategory.cancelled.sorted([cancelledLongAgo, cancelledRecently])

        XCTAssertEqual(sorted.map(\.id), ["cancelled-latest", "appt-later"])
    }

    // Legacy cancelled rows that predate the cancelled_at field fall back to the
    // appointment date and sort below rows that carry a cancellation timestamp.
    func testCancelledFallsBackToAppointmentDateWhenCancelledAtMissing() {
        let withStamp = makeBooking(
            id: "with-stamp",
            status: .canceled,
            datetime: Date(timeIntervalSince1970: 100),
            cancelledAt: Date(timeIntervalSince1970: 5_000)
        )
        let legacy = makeBooking(
            id: "legacy",
            status: .canceled,
            datetime: Date(timeIntervalSince1970: 1_000), // no stamp → falls back to this
            cancelledAt: nil
        )

        let sorted = BookingCategory.cancelled.sorted([legacy, withStamp])

        XCTAssertEqual(sorted.map(\.id), ["with-stamp", "legacy"])
    }

    // Upcoming stays soonest-first; past stays most-recent-appointment-first.
    func testUpcomingAndPastStillOrderByAppointmentDate() {
        let earlier = makeBooking(id: "earlier", datetime: Date(timeIntervalSince1970: 1_000))
        let later = makeBooking(id: "later", datetime: Date(timeIntervalSince1970: 2_000))

        XCTAssertEqual(BookingCategory.upcoming.sorted([later, earlier]).map(\.id), ["earlier", "later"])
        XCTAssertEqual(BookingCategory.past.sorted([earlier, later]).map(\.id), ["later", "earlier"])
    }
}

// MARK: - StaleBookingReconcileTests
//
// A category refresh upserts only what the server returns, so a booking that moved
// OUT of a category (e.g. cancelled elsewhere) must be detected and re-fetched —
// otherwise it lingers with its stale status in the wrong tab.

final class StaleBookingReconcileTests: XCTestCase {

    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    func testFlagsCategoryMemberMissingFromResponse() {
        let present = makeBooking(id: "present", status: .created, datetime: now.addingTimeInterval(3_600))
        let movedOut = makeBooking(id: "moved", status: .created, datetime: now.addingTimeInterval(7_200))
        let cancelled = makeBooking(id: "cancelled", status: .canceled, datetime: now.addingTimeInterval(3_600))

        let stale = BookingsRepositoryImpl.staleBookingIds(
            in: .upcoming,
            cached: [present, movedOut, cancelled],
            fetchedIds: ["present"],
            now: now
        )

        // `moved` still looks upcoming but wasn't returned → stale. `present` was
        // returned; `cancelled` doesn't bucket into upcoming.
        XCTAssertEqual(stale, ["moved"])
    }

    func testNoStaleWhenEveryCategoryMemberReturned() {
        let a = makeBooking(id: "a", status: .created, datetime: now.addingTimeInterval(3_600))
        let b = makeBooking(id: "b", status: .created, datetime: now.addingTimeInterval(7_200))

        let stale = BookingsRepositoryImpl.staleBookingIds(
            in: .upcoming,
            cached: [a, b],
            fetchedIds: ["a", "b"],
            now: now
        )

        XCTAssertTrue(stale.isEmpty)
    }
}

// MARK: - Booking factory (shared)

func makeBooking(
    id: String,
    status: BookingStatus = .created,
    datetime: Date = Date(timeIntervalSince1970: 1_700_000_000),
    cancelledAt: Date? = nil,
    crmType: SalonBookingProvider = .unknown,
    crmRecordId: String? = nil,
    bookingUrl: URL? = nil
) -> Booking {
    Booking(
        id: id,
        salonId: "salon-1",
        salonName: "Glossy Room",
        salonAddress: nil,
        salonImageURL: nil,
        coordinate: nil,
        bookingUrl: bookingUrl,
        crmType: crmType,
        crmRecordId: crmRecordId,
        status: status,
        datetime: datetime,
        endDatetime: nil,
        cancelledAt: cancelledAt,
        services: [],
        totalPrice: nil,
        currency: nil,
        durationMinutes: nil,
        timezone: nil
    )
}
