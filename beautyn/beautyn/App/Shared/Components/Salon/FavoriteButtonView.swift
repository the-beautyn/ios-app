import SwiftUI

// MARK: - FavoriteButtonView
//
// Matches Figma favorite circle button (bottom-right of salon card).
// Soft blush (#FADBFA) background, mauve heart icon.

struct FavoriteButtonView: View {

    var isFavorited: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .font(.system(size: 13))
                .foregroundStyle(Color.App.mauveVeil)
                .frame(width: 28, height: 28)
                .background(Color.App.softBlush, in: Circle())
        }
        .buttonStyle(.plain)
        .scaleEffect(isFavorited ? 1.1 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isFavorited)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    HStack(spacing: CGFloat.Spacing.lg) {
        FavoriteButtonView(isFavorited: false, onTap: {})
        FavoriteButtonView(isFavorited: true, onTap: {})
    }
    .padding()
}
#endif
