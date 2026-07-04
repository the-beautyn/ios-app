import SwiftUI

// MARK: - SearchHeaderView
//
// Matches Figma "Header" on the Search screen — white bar extending under the
// status bar, with the search-field pill and a round locate button. Both taps
// are forwarded to the view model (placeholders for now).

struct SearchHeaderView: View {

    /// Content height below the safe area: top padding (4) + field (44) + bottom padding (16).
    /// Keep in sync with the paddings in `body` — used to place map controls under the header.
    static let contentHeight: CGFloat = 64

    var onSearchTap: () -> Void
    var onLocationTap: () -> Void

    var body: some View {
        HStack(spacing: CGFloat.Spacing.sm) {
            searchField
            locationButton
        }
        .padding(.horizontal, CGFloat.Spacing.md)
        .padding(.top, CGFloat.Spacing.xs)
        .padding(.bottom, CGFloat.Spacing.md)
        .background(
            Color.App.white
                .ignoresSafeArea(edges: .top)
                .shadow(color: .black.opacity(0.15), radius: 4)
        )
    }

    // MARK: - Search field

    private var searchField: some View {
        Button(action: onSearchTap) {
            HStack(spacing: CGFloat.Spacing.xs + 2) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.App.gray)

                Text(Localization.searchHint)
                    .font(.App.footnote)
                    .foregroundStyle(Color.App.gray)

                Spacer()
            }
            // Figma 143:8236: 14pt inset, 44pt field height (min touch target).
            .padding(.horizontal, CGFloat.Spacing.md - 2)
            .frame(height: 44)
            .background(Color.App.gray.opacity(0.08))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Location button

    private var locationButton: some View {
        Button(action: onLocationTap) {
            Image(systemName: "location.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.App.text)
                .padding(.horizontal, CGFloat.Spacing.md)
                // Matches the search field height (Figma 44, min touch target).
                .frame(height: 44)
                .background(Color.App.gray.opacity(0.08))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    VStack {
        SearchHeaderView(onSearchTap: {}, onLocationTap: {})
        Spacer()
    }
    .background(Color.App.backgroundLight)
}
#endif
