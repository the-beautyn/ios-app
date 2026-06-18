import XCTest
@testable import beautyn

// MARK: - AppointmentDateFormatterTests
//
// Locks the salon-timezone rendering: a booking's UTC instant must read in the
// salon's local wall-clock when a `timeZone` is supplied, and fall back to the
// device timezone when it's nil.

final class AppointmentDateFormatterTests: XCTestCase {

    // 2026-06-09 15:30:00 UTC (summer → Kyiv is UTC+3, Los Angeles is UTC-7).
    private let instant = AppointmentDateFormatterTests.utc(2026, 6, 9, 15, 30)

    func testTimeStringRendersInSalonTimezone() {
        let kyiv = TimeZone(identifier: "Europe/Kyiv")!
        XCTAssertEqual(
            AppointmentDateFormatter.timeString(start: instant, end: nil, timeZone: kyiv),
            "18:30"
        )
    }

    func testTimeRangeRendersInSalonTimezone() {
        let kyiv = TimeZone(identifier: "Europe/Kyiv")!
        let end = instant.addingTimeInterval(90 * 60) // 17:00 UTC → 20:00 Kyiv
        XCTAssertEqual(
            AppointmentDateFormatter.timeString(start: instant, end: end, timeZone: kyiv),
            "18:30 – 20:00"
        )
    }

    func testTimeStringIsIndependentOfDeviceTimezone() {
        // Same instant, a different salon zone → a different wall-clock, proving
        // the output tracks the salon zone rather than the device.
        let la = TimeZone(identifier: "America/Los_Angeles")!
        XCTAssertEqual(
            AppointmentDateFormatter.timeString(start: instant, end: nil, timeZone: la),
            "8:30"
        )
    }

    func testNilTimezoneFallsBackToDevice() {
        let reference = DateFormatter()
        reference.dateFormat = "H:mm"
        reference.timeZone = .current
        XCTAssertEqual(
            AppointmentDateFormatter.timeString(start: instant, end: nil, timeZone: nil),
            reference.string(from: instant)
        )
    }

    func testRelativeDayPrefixIsComputedInSalonTimezone() {
        // The current instant is "today" in every timezone.
        let kyiv = TimeZone(identifier: "Europe/Kyiv")!
        let value = AppointmentDateFormatter.dateString(Date(), relativeDay: true, timeZone: kyiv)
        XCTAssertTrue(value.hasPrefix(Localization.commonToday))
    }

    // MARK: - Helpers

    private static func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.date(from: components)!
    }
}
