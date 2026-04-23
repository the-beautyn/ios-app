import SwiftUI

// MARK: - LabeledField
//
// Renders a Footnote-styled black label above an arbitrary field content.
// Matches the "Input with label" pattern from Figma (e.g. Set New Password).

struct LabeledField<Content: View>: View {

    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.xs) {
            Text(label)
                .font(.App.footnote)
                .foregroundStyle(Color.App.text)
            content()
        }
    }
}
