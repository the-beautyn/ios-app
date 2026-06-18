import SwiftUI

// MARK: - BookingActionRow
//
// A tappable row in the Booking Details sheet: leading icon, title + optional
// subtitle, trailing chevron (Figma 143:3880 "Labels&Icons"). Used for
// Add to calendar / Прокласти маршрут / Внести зміни / Забронювати знову.

struct BookingActionRow: View {

    let icon: String
    let title: String
    var subtitle: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CGFloat.Spacing.sm + 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.App.black)
                    .frame(width: 20, height: 20)

                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.App.footnote)
                        .foregroundStyle(Color.App.black)

                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.App.caption2)
                            .tracking(CGFloat.Tracking.caption2)
                            .foregroundStyle(Color.App.gray2)
                    }
                }

                Spacer(minLength: CGFloat.Spacing.sm)

                Image(systemName: "chevron.right")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.App.gray2)
            }
            .padding(.vertical, CGFloat.Spacing.xs)
            .padding(.trailing, CGFloat.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    VStack(spacing: 0) {
        BookingActionRow(icon: "calendar", title: "Додати в календар", action: {})
        BookingActionRow(
            icon: "map",
            title: "Прокласти маршрут",
            subtitle: "вул. Зеленицька, 15 (411), 05-091",
            action: {}
        )
        BookingActionRow(
            icon: "calendar.badge.clock",
            title: "Внести зміни",
            subtitle: "Перенести, відредагувати, відмінити.",
            action: {}
        )
    }
    .padding()
}
#endif
