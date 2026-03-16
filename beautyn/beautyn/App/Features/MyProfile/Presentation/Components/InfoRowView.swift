import SwiftUI

// MARK: - InfoRowView
//
// Matches Figma Personal Info detail rows.
// Bold label above, value text below.
// e.g. "Дата народження" / "21/02/2002"

struct InfoRowView: View {

    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.xxs) {
            Text(label)
                .font(.App.headline)
                .foregroundStyle(Color.App.text)

            Text(value)
                .font(.App.subheadline)
                .foregroundStyle(Color.App.gray2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, CGFloat.Spacing.sm)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: 0) {
        InfoRowView(label: "Дата народження", value: "21/02/2002")
        InfoRowView(label: "Номер телефону", value: "+380506314634")
        InfoRowView(label: "Пошта", value: "helga.altuhova@gmail.com")
        InfoRowView(label: "Місто", value: "Львів")
        InfoRowView(label: "Стать", value: "Жіноча")
    }
    .padding(.horizontal, CGFloat.Spacing.md)
}
#endif
