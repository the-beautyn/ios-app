import SwiftUI

// MARK: - SearchBarButton
//
// Matches Figma "Search Field (iPhone)" — tappable search bar that navigates to Search tab.
// Rounded pill with magnifying glass icon and placeholder text.

struct SearchBarButton: View {

    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CGFloat.Spacing.xs + 2) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.App.gray)

                Text(Localization.searchHint)
                    .font(.App.footnote)
                    .foregroundStyle(Color.App.gray)

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
            .background(Color.App.gray.opacity(0.08))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    SearchBarButton(onTap: {})
        .padding(.horizontal, CGFloat.Spacing.md)
}
#endif
