import SwiftUI

struct SettingsRowView: View {

    let title: String
    var isDestructive: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                Text(title)
                    .font(.App.body)
                    .foregroundStyle(isDestructive ? Color.App.red : Color.App.text)
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 68)
            .padding(.horizontal, CGFloat.Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 0) {
        SettingsRowView(title: "Terms of Service", onTap: {})
        SettingsRowView(title: "Privacy Policy", onTap: {})
        SettingsRowView(title: "Змінити пароль", onTap: {})
        SettingsRowView(title: "Вийти з акаунту", onTap: {})
        SettingsRowView(title: "Видалити акаунт", isDestructive: true, onTap: {})
    }
}
#endif
