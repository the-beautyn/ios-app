import SwiftUI

// MARK: - CalendarView
//
// Matches Figma booking date picker (node 143:3026).
// Displays a single month grid with prev/next navigation; weeks start on Monday.
// - Past dates (before `minSelectableDate`) are grayed out and non-selectable.
// - Today is outlined (sandstone border) when not selected.
// - The selected date is filled (clay-rose).
// - Prev/next-month days are not shown.
// - Month arrows gray out when the adjacent month is blocked.
// Emits `onMonthChanged` / `onDateSelected` so a host screen can load slots.

struct CalendarView: View {

    @Binding var selectedDate: Date?

    /// Optional per-day availability filter. `nil` = no filtering (all future days selectable).
    var availableDates: Set<Date>? = nil
    /// Dates before this day are grayed out and cannot be selected. Defaults to today.
    var minSelectableDate: Date = Date()
    /// Last navigable month. `nil` = unbounded forward navigation.
    var maxMonth: Date? = nil
    /// Fires with the new displayed month after the user taps a navigation arrow.
    var onMonthChanged: ((Date) -> Void)? = nil
    /// Fires with the tapped selectable date.
    var onDateSelected: ((Date) -> Void)? = nil

    @State private var displayedMonth: Date

    /// - Parameter initialMonth: month the grid opens on. `nil` = current month.
    init(
        selectedDate: Binding<Date?>,
        availableDates: Set<Date>? = nil,
        minSelectableDate: Date = Date(),
        maxMonth: Date? = nil,
        initialMonth: Date? = nil,
        onMonthChanged: ((Date) -> Void)? = nil,
        onDateSelected: ((Date) -> Void)? = nil
    ) {
        self._selectedDate = selectedDate
        self.availableDates = availableDates
        self.minSelectableDate = minSelectableDate
        self.maxMonth = maxMonth
        self.onMonthChanged = onMonthChanged
        self.onDateSelected = onDateSelected
        self._displayedMonth = State(initialValue: Self.calendar.startOfMonth(for: initialMonth ?? Date()))
    }

    /// Monday-first Ukrainian calendar — fixed so layout is deterministic regardless of device locale.
    private static let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2                       // Monday
        c.locale = Locale(identifier: "uk_UA")
        return c
    }()

    private var calendar: Calendar { Self.calendar }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: CGFloat.Spacing.xs), count: 7)

    /// Short weekday symbols rotated to start at `firstWeekday` (→ пн вт ср чт пт сб нд).
    private var weekdays: [String] {
        let symbols = calendar.shortWeekdaySymbols       // base order is Sunday-first
        let offset = calendar.firstWeekday - 1
        return Array(symbols[offset...] + symbols[..<offset])
    }

    var body: some View {
        VStack(spacing: CGFloat.Spacing.md) {
            monthHeader
            VStack(spacing: CGFloat.Spacing.xs) {
                weekdayHeader
                daysGrid
            }
        }
    }

    // MARK: - Month header

    private var monthHeader: some View {
        HStack {
            navButton(systemName: "arrow.left", enabled: canGoToPreviousMonth) {
                changeMonth(by: -1)
            }

            Spacer()

            Text(monthYearString)
                .font(.App.subheadline)
                .foregroundStyle(Color.App.text)

            Spacer()

            navButton(systemName: "arrow.right", enabled: canGoToNextMonth) {
                changeMonth(by: 1)
            }
        }
    }

    private func navButton(systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(enabled ? Color.App.text : Color.App.gray2)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    // MARK: - Weekday header

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.App.footnote)
                    .foregroundStyle(Color.App.gray2)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Days grid

    private var daysGrid: some View {
        LazyVGrid(columns: columns, spacing: CGFloat.Spacing.xs) {
            ForEach(daysInGrid, id: \.self) { date in
                if let date {
                    dayCell(date)
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
    }

    @ViewBuilder
    private func dayCell(_ date: Date) -> some View {
        let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false
        let isToday = calendar.isDateInToday(date)
        let isPast = date < calendar.startOfDay(for: minSelectableDate)
        let isUnavailable: Bool = {
            guard let availableDates else { return false }
            return !availableDates.contains { calendar.isDate($0, inSameDayAs: date) }
        }()
        let isSelectable = !isPast && !isUnavailable
        let dayNumber = calendar.component(.day, from: date)

        Button {
            guard isSelectable else { return }
            selectedDate = date
            onDateSelected?(date)
        } label: {
            Text("\(dayNumber)")
                .font(.App.subheadline)
                .foregroundStyle(dayForeground(isSelected: isSelected, isSelectable: isSelectable))
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(dayBackground(isSelected: isSelected, isToday: isToday))
        }
        .buttonStyle(.plain)
        .disabled(!isSelectable)
    }

    // MARK: - Day styling

    private func dayForeground(isSelected: Bool, isSelectable: Bool) -> Color {
        if isSelected { return Color.App.white }
        // Available (bookable) days are black; past / unavailable days are grayed out.
        return isSelectable ? Color.App.black : Color.App.gray2
    }

    @ViewBuilder
    private func dayBackground(isSelected: Bool, isToday: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.App.brown2)
        } else if isToday {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.App.beige1, lineWidth: 1)
        } else {
            Color.clear
        }
    }

    // MARK: - Navigation

    private var minMonth: Date { calendar.startOfMonth(for: minSelectableDate) }

    private var canGoToPreviousMonth: Bool {
        calendar.startOfMonth(for: displayedMonth) > minMonth
    }

    private var canGoToNextMonth: Bool {
        guard let maxMonth else { return true }
        return calendar.startOfMonth(for: displayedMonth) < calendar.startOfMonth(for: maxMonth)
    }

    private func changeMonth(by value: Int) {
        guard let next = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        displayedMonth = next
        onMonthChanged?(next)
    }

    // MARK: - Date math

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: displayedMonth).capitalized
    }

    private var daysInGrid: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }
        let weekday = calendar.component(.weekday, from: monthInterval.start)
        let leading = (weekday - calendar.firstWeekday + 7) % 7
        let daysInMonth = calendar.range(of: .day, in: .month, for: displayedMonth)?.count ?? 30

        var days: [Date?] = Array(repeating: nil, count: leading)
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                days.append(date)
            }
        }
        // Pad to complete the last row.
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }
}

// MARK: - Calendar extension

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    @Previewable @State var selected: Date? = Calendar.current.date(byAdding: .day, value: 1, to: Date())
    CalendarView(
        selectedDate: $selected,
        onMonthChanged: { print("month →", $0) },
        onDateSelected: { print("date →", $0) }
    )
    .padding(CGFloat.Spacing.md)
}
#endif
