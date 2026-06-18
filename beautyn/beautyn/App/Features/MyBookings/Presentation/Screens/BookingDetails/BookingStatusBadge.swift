import SwiftUI

// MARK: - BookingStatusBadge
//
// The status pill at the top of the Booking Details sheet. One style per booking
// state (Figma 143:3868 confirmed / 143:5150 cancelled / 143:5089 completed).

struct BookingStatusBadge: View {

    enum Style {
        case confirmed    // future
        case cancelled
        case completed    // past
    }

    let style: Style
    let text: String

    var body: some View {
        HStack(spacing: CGFloat.Spacing.xs) {
            Image(systemName: iconName)
                .font(.system(size: 11, weight: .regular))
            Text(text)
                .font(.App.caption1)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, CGFloat.Spacing.sm)
        .padding(.vertical, CGFloat.Spacing.xxs)
        .background(background, in: Capsule())
    }

    private var iconName: String {
        switch style {
        case .confirmed: return "checkmark"
        case .cancelled: return "xmark.circle"
        case .completed: return "checkmark.circle"
        }
    }

    private var foreground: Color {
        switch style {
        case .confirmed: return .App.oliveDeep
        case .cancelled: return .App.red
        case .completed: return .App.brown1
        }
    }

    private var background: Color {
        switch style {
        case .confirmed: return .App.sage
        case .cancelled: return .App.red.opacity(0.3)
        case .completed: return .App.beige2
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
        BookingStatusBadge(style: .confirmed, text: "Підтверджено")
        BookingStatusBadge(style: .cancelled, text: "Скасовано")
        BookingStatusBadge(style: .completed, text: "Завершено")
    }
    .padding()
}
#endif
