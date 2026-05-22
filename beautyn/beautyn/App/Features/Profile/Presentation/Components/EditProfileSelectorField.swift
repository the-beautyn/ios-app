import SwiftUI

// MARK: - EditProfileSelectorField
//
// A tappable read-only field shaped like `AppTextField` (50pt tall, 12pt
// corner radius, 1pt blue-transparency border). Shows a value or a placeholder
// + a trailing chevron. Used for the City and Sex rows in the Edit Profile
// form, where tapping opens a picker.

struct EditProfileSelectorField: View {

    let placeholder: String
    let value: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CGFloat.Spacing.sm) {
                Text(value?.isEmpty == false ? value! : placeholder)
                    .font(.App.footnote)
                    .foregroundStyle(value?.isEmpty == false ? Color.App.text : Color.App.gray2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.App.gray2)
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.App.blueTransparency, lineWidth: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: CGFloat.Spacing.md) {
        EditProfileSelectorField(placeholder: "Місто", value: nil, onTap: {})
        EditProfileSelectorField(placeholder: "Місто", value: "Львів", onTap: {})
    }
    .padding()
    .background(Color.App.backgroundLight)
}
#endif
