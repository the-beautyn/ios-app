import SwiftUI

// MARK: - TagBadgeView
//
// Matches Figma "PopularItemTitle" badge (sage green pill, top-left of salon card).
// Example: "Top 10 Masters"

struct TagBadgeView: View {

    let text: String

    var body: some View {
        Text(text)
            .font(.App.caption1)
            .foregroundStyle(Color.App.oliveDeep)
            .padding(.horizontal, CGFloat.Spacing.sm)
            .padding(.vertical, 2)
            .background(Color.App.sage, in: Capsule())
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    TagBadgeView(text: "Top 10 Masters")
        .padding()
}
#endif
