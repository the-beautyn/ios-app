import Foundation

// MARK: - ApiDateFormatter

/// Formats dates as the API's `yyyy-MM-dd` day strings.
enum ApiDateFormatter {

    /// Gregorian calendar so `yyyy-MM-dd` days stay stable even when the
    /// device uses a non-gregorian calendar.
    private static let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale(identifier: "en_US_POSIX")
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

    static func date(from string: String) -> Date? {
        formatter.date(from: string)
    }
}
