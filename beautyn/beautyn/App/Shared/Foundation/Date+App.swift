import Foundation

extension Date {
    /// Whether the receiver falls on a calendar day before today.
    var isBeforeToday: Bool {
        self < Calendar.current.startOfDay(for: Date())
    }
}
