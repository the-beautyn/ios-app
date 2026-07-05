import SwiftUI

// MARK: - SearchPillButton
//
// Bordered-capsule pill button matching Figma "SearchField" pills
// (143:8546 location / 143:8552 date) — icon + footnote label, same
// stroke recipe as `SearchBorderedField`.

struct SearchPillButton: View {

    let icon: Image
    let title: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CGFloat.Spacing.xs + 2) {
                icon
                    .font(.system(size: 14))
                    .foregroundStyle(Color.App.gray)

                Text(title)
                    .font(.App.footnote)
                    .foregroundStyle(Color.App.gray)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, CGFloat.Spacing.md - 2)
            .frame(height: 50)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay {
                Capsule().stroke(Color.App.blueTransparency, lineWidth: 1)
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    HStack(spacing: CGFloat.Spacing.sm + 4) {
        SearchPillButton(icon: Image(systemName: "location.fill"), title: "Київ", onTap: {})
        SearchPillButton(icon: Image(systemName: "calendar"), title: "Дата", onTap: {})
    }
    .padding(CGFloat.Spacing.md)
}
#endif
