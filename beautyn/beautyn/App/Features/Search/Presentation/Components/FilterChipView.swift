import SwiftUI

// MARK: - FilterChipView
//
// Matches Figma filter chips on the Search screen.
// e.g. "Тип послуги ▾", "Сортувати ▾", "Ціна ▾"
// Outlined pill; the active state swaps the hairline for a 2pt brown border
// (Figma 143:8432) — content stays the same.

struct FilterChipView: View {

    let title: String
    var isSelected: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CGFloat.Spacing.xs) {
                Text(title)
                    .font(.App.caption1)
                    .foregroundStyle(Color.App.text)

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.App.text)
            }
            .padding(.horizontal, CGFloat.Spacing.sm)
            // Figma: 6pt — closest tokens are xxs (4) and xs (8).
            .padding(.vertical, CGFloat.Spacing.xxs + 2)
            .background(
                Capsule()
                    .fill(Color.App.backgroundLight)
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? Color.App.brown2 : Color.App.blueTransparency,
                        lineWidth: isSelected ? 2 : 1
                    )
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
