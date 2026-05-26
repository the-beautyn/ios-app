import SwiftUI

// MARK: - SalonStickyActionBar
//
// Bottom-anchored action bar for the SalonProfile screen.
// Leading: "{count} опцій" caption.
// Trailing: primary "Записатись" button (fixed ~140pt wide).
// Background: solid white with a blue-transparency top hairline divider.

struct SalonStickyActionBar: View {

    let optionsCount: Int
    var ctaTitle: String
    var onBook: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            Text(Localization.salonOptionsCount(optionsCount))
                .font(.App.caption1)
                .foregroundStyle(Color.App.gray2)

            Spacer()

            AppButton(
                title: ctaTitle,
                style: .primary,
                size: .big,
                action: onBook
            )
            // Hug the label instead of pinning to a fixed width, so the CTA
            // stays on one line regardless of localized title length.
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, CGFloat.Spacing.md)
        .padding(.top, CGFloat.Spacing.sm)
        .padding(.bottom, CGFloat.Spacing.sm)
        .background(Color.App.white)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.App.blueTransparency)
                .frame(height: 1)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    VStack {
        Spacer()
        SalonStickyActionBar(
            optionsCount: 36,
            ctaTitle: Localization.salonBookButton,
            onBook: {}
        )
    }
    .background(Color.App.beige2)
}
#endif
