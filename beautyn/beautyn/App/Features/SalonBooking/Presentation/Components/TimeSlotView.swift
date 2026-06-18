import SwiftUI

// MARK: - TimeSlotView
//
// Matches Figma time slot pill chips in the booking date picker and specialist tab.
// Selected: clay-rose fill (#907064), white text.
// Unselected: white fill, black text, faint hairline border.

struct TimeSlotView: View {

    let time: String
    var isSelected: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(time)
                .font(.App.subheadline)
                .foregroundStyle(isSelected ? Color.App.white : Color.App.black)
                .padding(.horizontal, CGFloat.Spacing.md)
                .padding(.vertical, CGFloat.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .fill(isSelected ? Color.App.brown2 : Color.App.backgroundLight)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .stroke(isSelected ? Color.clear : Color.App.blueTransparency, lineWidth: 1)
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
