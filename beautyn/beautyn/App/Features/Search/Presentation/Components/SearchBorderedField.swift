import SwiftUI

// MARK: - SearchBorderedField
//
// Bordered-capsule search input matching Figma "SearchField" (143:8537 /
// 143:8597) — 50pt tall, hairline `blueTransparency` stroke, magnifying
// glass + footnote text. Same recipe as LocationPickerView's field, shared
// by the Search and Локація screens.

struct SearchBorderedField: View {

    let placeholder: String
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding? = nil
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: CGFloat.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(Color.App.gray2)

            textField
        }
        // Figma: 14pt inset, 50pt field height.
        .padding(.horizontal, CGFloat.Spacing.md - 2)
        .frame(height: 50)
        .overlay {
            Capsule().stroke(Color.App.blueTransparency, lineWidth: 1)
        }
    }

    @ViewBuilder
    private var textField: some View {
        let base = TextField(placeholder, text: $text)
            .font(.App.footnote)
            .foregroundStyle(Color.App.text)
            .tint(Color.App.brown1)
            .submitLabel(.search)
            .autocorrectionDisabled()
            .onSubmit { onSubmit?() }

        if let isFocused {
            base.focused(isFocused)
        } else {
            base
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    VStack(spacing: CGFloat.Spacing.md) {
        SearchBorderedField(placeholder: "Уведіть назву салону", text: .constant(""))
        SearchBorderedField(placeholder: "Уведіть назву салону", text: .constant("Nail bar"))
    }
    .padding(CGFloat.Spacing.md)
}
#endif
