import SwiftUI

// MARK: - AppNavigationBar
//
// Matches Figma navigation bars:
//   Back only          — chevron circle button, no title
//   Back + title       — chevron + centered title (e.g. Date picker)
//   Back + title + action — chevron + centered title + trailing icon circle (e.g. Change Password)

struct AppNavigationBar<Trailing: View>: View {

    var title: String? = nil
    var onBack: (() -> Void)? = nil
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        ZStack {
            if let title {
                Text(title)
                    .font(.App.headline)
                    .foregroundStyle(Color.App.text)
                    .lineLimit(1)
            }

            HStack {
                if let onBack {
                    NavCircleButton(
                        icon: Image(systemName: "chevron.left"),
                        action: onBack
                    )
                }
                Spacer()
                trailing()
            }
        }
        .frame(height: 44)
        .padding(.horizontal, CGFloat.Spacing.md)
    }
}

// MARK: - Convenience — no trailing

extension AppNavigationBar where Trailing == EmptyView {
    init(title: String? = nil, onBack: (() -> Void)? = nil) {
        self.title = title
        self.onBack = onBack
        self.trailing = { EmptyView() }
    }
}

// MARK: - NavCircleButton (private)

struct NavCircleButton: View {
    let icon: Image
    let action: () -> Void
    var size: CGFloat = 36
    var iconSize: CGFloat = 14

    var body: some View {
        Button(action: action) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .fontWeight(.semibold)
                .foregroundStyle(Color.App.text)
                .frame(width: size, height: size)
                .background(Color.App.beige2)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Variants") {
    VStack(spacing: CGFloat.Spacing.xl) {
        AppNavigationBar(onBack: {})

        AppNavigationBar(title: "Змінити пароль", onBack: {})

        AppNavigationBar(title: "Змінити пароль", onBack: {}) {
            NavCircleButton(
                icon: Image(systemName: "checkmark"),
                action: {}
            )
        }

        AppNavigationBar {
            HStack(spacing: CGFloat.Spacing.sm) {
                NavCircleButton(icon: Image(systemName: "square.and.arrow.up"), action: {})
                NavCircleButton(icon: Image(systemName: "heart"), action: {})
            }
        }
    }
    .padding()
    .background(Color.App.backgroundLight)
}
#endif
