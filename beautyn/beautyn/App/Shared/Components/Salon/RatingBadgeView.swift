import SwiftUI

// MARK: - RatingBadgeView
//
// Matches Figma "PopularItemRating" badge (sand pill, top-right of salon card).
// Example: ⭐ 4.5

struct RatingBadgeView: View {

    let rating: Double

    var body: some View {
        HStack(spacing: CGFloat.Spacing.xs) {
            Image(systemName: "star.fill")
                .font(.system(size: 11))
                .foregroundStyle(Color.App.sun)

            Text(formatted)
                .font(.App.caption1)
                .foregroundStyle(Color.App.gray)
        }
        .padding(.horizontal, CGFloat.Spacing.sm)
        .padding(.vertical, 2)
        .background(Color.App.sand, in: Capsule())
    }

    private var formatted: String {
        rating.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", rating)
            : String(format: "%.1f", rating)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    HStack {
        RatingBadgeView(rating: 4.5)
        RatingBadgeView(rating: 5)
    }
    .padding()
}
#endif
