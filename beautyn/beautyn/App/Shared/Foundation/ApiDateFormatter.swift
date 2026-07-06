import Foundation

// MARK: - ApiDateFormatter

/// Formats dates as the API's `yyyy-MM-dd` day strings.
enum ApiDateFormatter {

    /// Gregorian / uk_UA calendar, matching `CalendarView` so the API's
    /// `yyyy-MM-dd` days line up with the grid's days.
    private static let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale(identifier: "uk_UA")
        return c
    }()

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = calendar
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}
