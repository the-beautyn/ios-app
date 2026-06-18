import SwiftUI

// MARK: - SalonSearchField
//
// iOS-style search field matching the Figma reference — gray translucent
// background, magnifying glass icon, footnote-sized placeholder/text.
// Used inside the SalonProfile tab content for filtering services /
// specialists locally.

struct SalonSearchField: View {

    let placeholder: String
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding? = nil

    private let height: CGFloat = 32

    var body: some View {
        HStack(spacing: CGFloat.Spacing.xs + 2) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundStyle(Color.App.gray)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.App.footnote)
                        .foregroundStyle(Color.App.gray)
                }
                textField
            }
        }
        .padding(.leading, CGFloat.Spacing.sm)
        .padding(.trailing, CGFloat.Spacing.sm + 6)
        .frame(height: height)
        .background(Color.App.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder
    private var textField: some View {
        let base = TextField("", text: $text)
            .font(.App.footnote)
            .foregroundStyle(Color.App.text)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

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
        SalonSearchField(placeholder: "Пошук", text: .constant(""))
        SalonSearchField(placeholder: "Пошук", text: .constant("manicure"))
    }
    .padding()
    .background(Color.App.white)
}
#endif
