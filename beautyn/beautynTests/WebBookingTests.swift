import XCTest
import Combine
import WebKit
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
        // Method-1 selector targets the "view my booking" CTA's href (locale-proof).
        XCTAssertEqual(config.completionLinkSelector, "a[href*=\"/booking/\"]")

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

    // MARK: - Booking-id extraction (against a real WKWebView DOM)

    @MainActor
    func testExtractionMethod1PrefersCtaHrefAndSkipsOldBooking() async throws {
        let newId = "c2247a8c-cd55-417a-a466-573aeca086d6"
        let oldId = "11111111-2222-3333-4444-555555555555"
        // Old booking still referenced (stale link + Nuxt state); the accent CTA
        // points to the NEW booking. The label's locale is irrelevant — we key off
        // the href. Method 1 must skip the excluded old id and return the new one.
        let html = """
        <html><head>
        <script>window.__NUXT__ = { state: { prev: "booking/\(oldId)" } };</script>
        </head><body>
        <a href="/co/booking/\(oldId)" class="aw-button">stale</a>
        <a href="/co/booking/\(newId)" class="aw-button aw-button--color-accent" aria-label="Переглянути мій запис">View</a>
        </body></html>
        """
        let id = try await extractBookingId(
            html: html,
            selector: WebBookingConfiguration.easyWeek.completionLinkSelector,
            excludeId: oldId
        )
        XCTAssertEqual(id, newId)
    }

    @MainActor
    func testExtractionFallsBackToUniqueNonExcludedId() async throws {
        // No CTA anchor → Method 1 finds nothing → Method 2 returns the unique id
        // that isn't the excluded old booking.
        let newId = "c2247a8c-cd55-417a-a466-573aeca086d6"
        let oldId = "11111111-2222-3333-4444-555555555555"
        let html = "<html><body>booking/\(oldId) booking/\(newId)</body></html>"
        let id = try await extractBookingId(html: html, selector: nil, excludeId: oldId)
        XCTAssertEqual(id, newId)
    }

    @MainActor
    func testExtractionReturnsEmptyWhenAmbiguous() async throws {
        // Two candidates, neither excluded → ambiguous → no false completion.
        let a = "aaaaaaaa-1111-2222-3333-444444444444"
        let b = "bbbbbbbb-1111-2222-3333-444444444444"
        let html = "<html><body>booking/\(a) booking/\(b)</body></html>"
        let id = try await extractBookingId(html: html, selector: nil, excludeId: nil)
        XCTAssertEqual(id, "")
    }

    @MainActor
    private func extractBookingId(html: String, selector: String?, excludeId: String?) async throws -> String {
        let webView = WKWebView()
        let waiter = WebViewLoadWaiter()
        webView.navigationDelegate = waiter
        webView.loadHTMLString(html, baseURL: URL(string: "https://booking.easyweek.io/co/thank-you"))
        await waiter.waitForLoad()
        let js = WebBookingWebView.bookingIdExtractionJS(
            patterns: WebBookingConfiguration.easyWeek.bookingIdRegexes,
            linkSelector: selector,
            excludeId: excludeId
        )
        let result = try await webView.evaluateJavaScript(js)
        return (result as? String) ?? ""
    }

    // MARK: - Confirm use case

    @MainActor
    func testConfirmFetchesFullBookingAndCachesIt() async throws {
        let repo = MockEasyweekBookingRepository(bookingId: "local-booking-1")
        let bookings = MockBookingsRepository()
        bookings.refreshBookingResult = Self.makeBooking(id: "local-booking-1")

        let sut = ConfirmEasyweekBookingUseCaseImpl(
            repository: repo,
            bookingsRepository: bookings
        )

        let booking = try await sut.execute(salonId: "salon-9", bookingUuid: "ew-uuid")

        XCTAssertEqual(repo.confirmedSalonId, "salon-9")
        XCTAssertEqual(repo.confirmedBookingUuid, "ew-uuid")
        XCTAssertEqual(bookings.refreshedId, "local-booking-1")
        XCTAssertEqual(booking.id, "local-booking-1")
        // The full booking is cached so Home / MyBookings see it.
        XCTAssertNotNil(bookings.stored["local-booking-1"])
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
            crmType: .easyweek,
            crmRecordId: nil,
            status: .created,
            datetime: Date(timeIntervalSince1970: 0),
            endDatetime: nil,
            cancelledAt: nil,
            services: [],
            totalPrice: nil,
            currency: nil,
            durationMinutes: nil,
            timezone: nil
        )
    }
}

// MARK: - Mocks

/// Resumes once a `WKWebView` finishes loading, so the extraction tests can run JS
/// against a fully-parsed DOM. WebKit delivers delegate callbacks on the main
/// thread, the same context `waitForLoad()` is awaited from. Handles the case
/// where the load finishes before `await`.
private final class WebViewLoadWaiter: NSObject, WKNavigationDelegate {
    private var continuation: CheckedContinuation<Void, Never>?
    private var finished = false

    func waitForLoad() async {
        await withCheckedContinuation { cont in
            if finished { cont.resume() } else { continuation = cont }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        finished = true
        continuation?.resume()
        continuation = nil
    }
}

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
