import SwiftUI

// MARK: - ProfileMenuRowView
//
// Matches Figma Profile settings list rows (node 1:8575–1:8579).
// Icon + label + trailing accessory (chevron or toggle).

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
            HStack(spacing: CGFloat.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundStyle(Color.App.gray2)
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.App.body)
                    .foregroundStyle(Color.App.text)

                Spacer()

                trailingView
            }
            .frame(height: 68)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var trailingView: some View {
        switch trailing {
        case .chevron:
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.App.gray2)

        case .toggle(let binding):
            // Figma `colors/green` = iOS system green (#34C759).
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(.green)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    @Previewable @State var notificationsOn = true
    VStack(spacing: 0) {
        ProfileMenuRowView(icon: "person.fill", title: "Персональні дані", onTap: {})
        ProfileMenuRowView(icon: "bell.fill", title: "Нотифікації", trailing: .toggle($notificationsOn))
        ProfileMenuRowView(icon: "heart.fill", title: "Обрані салони", onTap: {})
        ProfileMenuRowView(icon: "gearshape.fill", title: "Налаштування", onTap: {})
        ProfileMenuRowView(icon: "globe", title: "Мова", onTap: {})
    }
    .padding(.horizontal, CGFloat.Spacing.md)
}
#endif
