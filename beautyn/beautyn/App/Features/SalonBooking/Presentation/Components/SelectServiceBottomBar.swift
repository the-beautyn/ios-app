import SwiftUI

// MARK: - SelectServiceBottomBar
//
// Bottom-anchored bar for the SelectService screen.
// Top row: total duration (leading) and a tappable "Всього: X грн" + pencil
// stack (trailing) that opens the edit-services sheet.
// Below: full-width primary "Продовжити" button.

struct SelectServiceBottomBar: View {

    let totalDurationText: String
    let totalPriceText: String
    let canEdit: Bool
    let canContinue: Bool
    let onEdit: () -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: CGFloat.Spacing.sm + CGFloat.Spacing.xs) {
            HStack(alignment: .center) {
                Text(totalDurationText)
                    .font(.App.caption1)
                    .foregroundStyle(Color.App.gray2)

                Spacer()

                Button(action: onEdit) {
                    HStack(spacing: CGFloat.Spacing.xs) {
                        Text(totalPriceText)
                            .font(.App.footnoteSemibold)
                            .foregroundStyle(Color.App.black)

                        Image(systemName: "pencil")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.App.black)
                    }
                }
                .buttonStyle(.plain)
                .disabled(!canEdit)
                .opacity(canEdit ? 1 : 0.5)
            }

            AppButton(
                title: Localization.continueButton,
                style: .primary,
                size: .big,
                isDisabled: !canContinue,
                action: onContinue
            )
        }
        .padding(.horizontal, CGFloat.Spacing.md)
        .padding(.top, CGFloat.Spacing.md)
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
        SelectServiceBottomBar(
            totalDurationText: "0 хв.",
            totalPriceText: "Всього: 0 грн",
            canEdit: false,
            canContinue: false,
            onEdit: {},
            onContinue: {}
        )
        SelectServiceBottomBar(
            totalDurationText: "180 хв.",
            totalPriceText: "Всього: 1400 грн",
            canEdit: true,
            canContinue: true,
            onEdit: {},
            onContinue: {}
        )
    }
    .background(Color.App.beige2)
}
#endif
