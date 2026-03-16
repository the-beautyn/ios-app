import SwiftUI

// MARK: - CalendarView
//
// Matches Figma booking date picker and Search filter calendar.
// Displays a month grid with prev/next navigation.
// Supports single-date selection; today is outlined if not selected.

struct CalendarView: View {

    @Binding var selectedDate: Date?
    var availableDates: Set<Date>? = nil   // nil = all dates available

    @State private var displayedMonth: Date = Calendar.current.startOfMonth(for: Date())

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private var weekdays: [String] { Calendar.current.shortWeekdaySymbols }

    var body: some View {
        VStack(spacing: CGFloat.Spacing.md) {
            monthHeader
            weekdayHeader
            daysGrid
        }
    }

    // MARK: - Month header

    private var monthHeader: some View {
        HStack {
            Button {
                displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.App.text)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)

            Spacer()

            Text(monthYearString)
                .font(.App.headline)
                .foregroundStyle(Color.App.text)

            Spacer()

            Button {
                displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.App.text)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Weekday header

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.App.caption2)
                    .tracking(CGFloat.Tracking.caption2)
                    .foregroundStyle(Color.App.gray2)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, CGFloat.Spacing.xs)
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
                    Color.clear.frame(height: 36)
                }
            }
        }
    }

    @ViewBuilder
    private func dayCell(_ date: Date) -> some View {
        let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false
        let isToday = calendar.isDateInToday(date)
        let isAvailable = availableDates == nil || availableDates!.contains { calendar.isDate($0, inSameDayAs: date) }
        let dayNumber = calendar.component(.day, from: date)

        Button {
            guard isAvailable else { return }
            selectedDate = isSelected ? nil : date
        } label: {
            Text("\(dayNumber)")
                .font(.App.subheadline)
                .foregroundStyle(foregroundColor(isSelected: isSelected, isToday: isToday, isAvailable: isAvailable))
                .frame(width: 36, height: 36)
                .background(background(isSelected: isSelected, isToday: isToday))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
        .opacity(isAvailable ? 1 : 0.3)
    }

    // MARK: - Helpers

    private func foregroundColor(isSelected: Bool, isToday: Bool, isAvailable: Bool) -> Color {
        if isSelected { return Color.App.white }
        return Color.App.text
    }

    @ViewBuilder
    private func background(isSelected: Bool, isToday: Bool) -> some View {
        if isSelected {
            Circle().fill(Color.App.brown1)
        } else if isToday {
            Circle().stroke(Color.App.brown1, lineWidth: 1)
        } else {
            Color.clear
        }
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: displayedMonth).capitalized
    }

    private var daysInGrid: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start) - 1
        let daysInMonth = calendar.range(of: .day, in: .month, for: displayedMonth)?.count ?? 30

        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                days.append(date)
            }
        }
        // Pad to complete last row
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
    @Previewable @State var selected: Date? = Date()
    CalendarView(selectedDate: $selected)
        .padding(CGFloat.Spacing.md)
}
#endif
