import Foundation

// MARK: - AppointmentDateFormatter
//
// Shared date / time formatting for the appointment cards (Home "next
// appointment" and the My Bookings list) so both render identically. With
// `relativeDay`, near days get a "Сьогодні" / "Завтра" / "Вчора" prefix; all
// other days fall back to the full weekday format.
//
// `timeZone` pins the rendering to the salon's local time (an IANA zone), so a
// booking reads in salon-local wall-clock regardless of the device timezone —
// matching the booking flow. `nil` falls back to the device timezone (the
// original behavior). All call sites are @MainActor, so mutating the shared
// formatters' `timeZone` per call is serialized and safe.

enum AppointmentDateFormatter {

    static func dateString(_ date: Date, relativeDay: Bool, timeZone: TimeZone? = nil) -> String {
        let zone = timeZone ?? .current
        if relativeDay {
            var calendar = Calendar.current
            calendar.timeZone = zone
            let prefix: String?
            if calendar.isDateInToday(date) {
                prefix = Localization.commonToday
            } else if calendar.isDateInTomorrow(date) {
                prefix = Localization.commonTomorrow
            } else if calendar.isDateInYesterday(date) {
                prefix = Localization.commonYesterday
            } else {
                prefix = nil
            }
            if let prefix {
                dayMonthFormatter.timeZone = zone
                return "\(prefix), \(dayMonthFormatter.string(from: date))"
            }
        }
        weekdayFormatter.timeZone = zone
        return weekdayFormatter.string(from: date).capitalized
    }

    static func timeString(start: Date, end: Date?, timeZone: TimeZone? = nil) -> String {
        let zone = timeZone ?? .current
        let formatter = timeFormatter.copy() as! DateFormatter
        formatter.timeZone = zone
        var value = formatter.string(from: start)
        if let end {
            value += " – " + formatter.string(from: end)
        }
        return value
    }

    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .appDisplay
        formatter.dateFormat = "EEEE, d MMM yyyy"
        return formatter
    }()

    private static let dayMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .appDisplay
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm"
        return formatter
    }()
}
