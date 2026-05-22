import SwiftUI

// MARK: - SectionHeaderView
//
// Matches Figma section headers on the Home screen.
// e.g. "Збережені 🩷 >" / "Популярні ⭐️ >"
// Title with emoji + a trailing chevron that triggers "see all".

struct SectionHeaderView: View {

    let title: String
    var onSeeAll: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: CGFloat.Spacing.xs) {
            Text(title)
                .font(.App.headline)
                .foregroundStyle(Color.App.text)

            if onSeeAll != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.App.text)
            }

            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture { onSeeAll?() }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: CGFloat.Spacing.md) {
        SectionHeaderView(title: "Збережені 🩷", onSeeAll: {})
        SectionHeaderView(title: "Популярні ⭐️", onSeeAll: {})
        SectionHeaderView(title: "Nails доступні сьогодні 💅🏼", onSeeAll: {})
        SectionHeaderView(title: "Перукар біля тебе 💇🏻‍♀️", onSeeAll: {})
        SectionHeaderView(title: "No chevron")
    }
    .padding(CGFloat.Spacing.md)
}
#endif
