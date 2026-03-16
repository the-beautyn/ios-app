import SwiftUI

// MARK: - ProfileMenuRowView
//
// Matches Figma Profile settings list rows.
// Icon + label + trailing accessory (chevron or toggle).
// e.g. Персональні дані >, Нотифікації (toggle), Обрані салони >, Мова >

struct ProfileMenuRowView: View {

    enum Trailing {
        case chevron
        case toggle(Binding<Bool>)
    }

    let icon: String            // SF Symbol name
    let title: String
    var trailing: Trailing = .chevron
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: CGFloat.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.App.gray)
                    .frame(width: 22, height: 22)

                Text(title)
                    .font(.App.body)
                    .foregroundStyle(Color.App.text)

                Spacer()

                trailingView
            }
            .padding(.vertical, CGFloat.Spacing.md)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) { Divider() }
    }

    @ViewBuilder
    private var trailingView: some View {
        switch trailing {
        case .chevron:
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.App.gray2)

        case .toggle(let binding):
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(Color.App.success)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    @Previewable @State var notificationsOn = true
    VStack(spacing: 0) {
        ProfileMenuRowView(icon: "person.crop.circle", title: "Персональні дані", onTap: {})
        ProfileMenuRowView(icon: "bell", title: "Нотифікації", trailing: .toggle($notificationsOn))
        ProfileMenuRowView(icon: "heart", title: "Обрані салони", onTap: {})
        ProfileMenuRowView(icon: "gearshape", title: "Налаштування", onTap: {})
        ProfileMenuRowView(icon: "globe", title: "Мова", onTap: {})
    }
    .padding(.horizontal, CGFloat.Spacing.md)
}
#endif
