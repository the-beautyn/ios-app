import SwiftUI

// MARK: - TimeSlotView
//
// Matches Figma time slot pill chips in the booking date picker and specialist tab.
// Selected: brown fill (#5A483A), white text.
// Unselected: white fill, brown text, brown border.

struct TimeSlotView: View {

    let time: String
    var isSelected: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(time)
                .font(.App.subheadline)
                .foregroundStyle(isSelected ? Color.App.white : Color.App.brown1)
                .padding(.horizontal, CGFloat.Spacing.md)
                .padding(.vertical, CGFloat.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .fill(isSelected ? Color.App.brown1 : Color.App.backgroundLight)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .stroke(isSelected ? Color.clear : Color.App.brown1, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: CGFloat.Spacing.sm) {
            TimeSlotView(time: "08:00", isSelected: true, onTap: {})
            TimeSlotView(time: "08:20", isSelected: false, onTap: {})
            TimeSlotView(time: "09:20", isSelected: false, onTap: {})
            TimeSlotView(time: "11:00", isSelected: false, onTap: {})
            TimeSlotView(time: "12:20", isSelected: false, onTap: {})
        }
        .padding(.horizontal, CGFloat.Spacing.md)
    }
    .padding(.vertical, CGFloat.Spacing.md)
}
#endif
