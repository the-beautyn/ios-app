import SwiftUI

// MARK: - FilterChipView
//
// Matches Figma filter chips on the Search screen.
// e.g. "Тип послуги ▾", "Сортувати ▾", "Ціна ▾"
// Outlined pill, active state has brown fill.

struct FilterChipView: View {

    let title: String
    var isSelected: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CGFloat.Spacing.xs) {
                Text(title)
                    .font(.App.caption1)
                    .foregroundStyle(isSelected ? Color.App.white : Color.App.text)

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isSelected ? Color.App.white : Color.App.text)
            }
            .padding(.horizontal, CGFloat.Spacing.sm)
            // Figma: 6pt — closest tokens are xxs (4) and xs (8).
            .padding(.vertical, CGFloat.Spacing.xxs + 2)
            .background(
                Capsule()
                    .fill(isSelected ? Color.App.brown1 : Color.App.backgroundLight)
            )
            .overlay(
                Capsule()
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
    HStack(spacing: CGFloat.Spacing.sm) {
        FilterChipView(title: "Тип послуги", isSelected: true, onTap: {})
        FilterChipView(title: "Сортувати", isSelected: false, onTap: {})
        FilterChipView(title: "Ціна", isSelected: false, onTap: {})
    }
    .padding(CGFloat.Spacing.md)
}
#endif
