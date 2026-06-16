import XCTest
import Combine
@testable import beautyn

// MARK: - WebBookingTests
//
// Covers the provider-agnostic web-booking engine config (EasyWeek wiring) and
// the EasyWeek confirm use case orchestration.

final class WebBookingTests: XCTestCase {

    // MARK: - Configuration / provider switchboard

    func testEasyWeekConfigurationShape() {
        let config = WebBookingConfiguration.easyWeek

        XCTAssertEqual(config.autofillPathSuffix, "/confirm")
        XCTAssertEqual(config.completionPathSuffix, "/thank-you")
        XCTAssertEqual(config.fields.map(\.kind), [.firstName, .lastName, .email, .phone])
        XCTAssertFalse(config.bookingIdRegexes.isEmpty)

        // Email/phone narrow by input type; name fields don't.
        let email = config.fields.first { $0.kind == .email }
        XCTAssertEqual(email?.preferredInputTypes, ["email"])
        let phone = config.fields.first { $0.kind == .phone }
        XCTAssertEqual(phone?.preferredInputTypes, ["tel"])
    }

    func testProviderSwitchboardOnlyMapsEasyWeek() {
        XCTAssertEqual(SalonBookingProvider.easyweek.webBookingConfiguration, .easyWeek)
        XCTAssertNil(SalonBookingProvider.altegio.webBookingConfiguration)
        XCTAssertNil(SalonBookingProvider.unknown.webBookingConfiguration)
    }

    func testBookingIdRegexMatchesEasyWeekThankYouPayload() {
        let uuid = "0a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d"
        let html = "<a href=\"/booking/\(uuid)/thank-you\">ok</a>"
        let pattern = WebBookingConfiguration.easyWeek.bookingIdRegexes[0]
        let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        let range = NSRange(html.startIndex..., in: html)
        let match = regex?.firstMatch(in: html, range: range)
        XCTAssertNotNil(match)
        if let match, let r = Range(match.range(at: 1), in: html) {
            XCTAssertEqual(String(html[r]), uuid)
        }
    }

    // MARK: - Confirm use case

    func testConfirmFetchesFullBookingAndNotifiesBus() async throws {
        let repo = MockEasyweekBookingRepository(bookingId: "local-booking-1")
        let getById = MockGetBookingByIdUseCase(booking: Self.makeBooking(id: "local-booking-1"))
        let bus = BookingEventBusImpl()

        var received: BookingCreatedEvent?
        var cancellables = Set<AnyCancellable>()
        bus.bookingCreated.sink { received = $0 }.store(in: &cancellables)

        let sut = ConfirmEasyweekBookingUseCaseImpl(
            repository: repo,
            getBookingByIdUseCase: getById,
            bookingEventBus: bus
        )

        let booking = try await sut.execute(salonId: "salon-9", bookingUuid: "ew-uuid")

        XCTAssertEqual(repo.confirmedSalonId, "salon-9")
        XCTAssertEqual(repo.confirmedBookingUuid, "ew-uuid")
        XCTAssertEqual(getById.requestedId, "local-booking-1")
        XCTAssertEqual(booking.id, "local-booking-1")
        XCTAssertEqual(received, BookingCreatedEvent(bookingId: "local-booking-1", salonId: "salon-9"))
    }

    // MARK: - Helpers

    private static func makeBooking(id: String) -> Booking {
        Booking(
            id: id,
            salonId: "salon-9",
            salonName: "Glossy Room",
            salonAddress: nil,
            salonImageURL: nil,
            coordinate: nil,
            bookingUrl: nil,
            status: .created,
            datetime: Date(timeIntervalSince1970: 0),
            endDatetime: nil,
            services: [],
            totalPrice: nil,
            currency: nil,
            durationMinutes: nil,
            timezone: nil
        )
    }
}

// MARK: - Mocks

private final class MockEasyweekBookingRepository: EasyweekBookingRepository {
    private let bookingId: String
    private(set) var confirmedSalonId: String?
    private(set) var confirmedBookingUuid: String?

    init(bookingId: String) { self.bookingId = bookingId }

    func confirm(salonId: String, bookingUuid: String) async throws -> String {
        confirmedSalonId = salonId
        confirmedBookingUuid = bookingUuid
        return bookingId
    }
}

private final class MockGetBookingByIdUseCase: GetBookingByIdUseCase {
    private let booking: Booking
    private(set) var requestedId: String?

    init(booking: Booking) { self.booking = booking }

    func execute(id: String) async throws -> Booking {
        requestedId = id
        return booking
    }
}
