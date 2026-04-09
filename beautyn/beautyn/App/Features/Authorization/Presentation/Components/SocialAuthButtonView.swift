import SwiftUI

// MARK: - SocialAuthButtonView
//
// Matches Figma "Продовжити з Apple" / "Продовжити з Google" buttons.
// White background, 1pt gray border, icon on the left, centered title.

struct SocialAuthButtonView: View {

    enum Provider {
        case apple
        case google

        var title: String {
            switch self {
            case .apple:  return Localization.authContinueApple
            case .google: return Localization.authContinueGoogle
            }
        }

        var icon: String {
            switch self {
            case .apple:  return "apple.logo"
            case .google: return "ic_google"
            }
        }

        var usesSystemImage: Bool {
            switch self {
            case .apple:  return true
            case .google: return false
            }
        }
    }

    let provider: Provider
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Group {
                    if provider.usesSystemImage {
                        Image(systemName: provider.icon)
                            .font(.system(size: 20))
                    } else {
                        Image(provider.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                }
                .foregroundStyle(Color.App.text)

                Text(provider.title)
                    .font(.App.headline)
                    .foregroundStyle(Color.App.text)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Color.App.backgroundLight)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.App.blueTransparency, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    VStack(spacing: CGFloat.Spacing.sm) {
        SocialAuthButtonView(provider: .apple, action: {})
        SocialAuthButtonView(provider: .google, action: {})
    }
    .padding(CGFloat.Spacing.md)
    .background(Color.App.backgroundLight)
}
#endif
