import SwiftUI

// MARK: - AppButton
//
// Matches Figma "Beautyn / Buttons" components:
//   Big button   — 327 × 52 pt, corner 12, Medium/17
//   Small button — 128 × 32 pt, corner 12, Regular/15
//
// Variants:  .primary   (brown fill, white text)
//            .secondary (white fill, brown text, optional stroke)

struct AppButton: View {

    // MARK: - Types

    enum Style {
        /// Filled brown background, white label.
        case primary
        /// White background, brown label. Pass `outlined: true` to add a 1 pt stroke.
        case secondary(outlined: Bool = false)
    }

    enum Size {
        /// 327 × 52, Medium / 17
        case big
        /// 128 × 32, Regular / 15
        case small
    }

    // MARK: - Properties

    let title: String
    var style: Style = .primary
    var size: Size = .big
    var icon: Image? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(AppButtonStyle(style: style, size: size, isDisabled: isDisabled || isLoading))
        .disabled(isDisabled || isLoading)
    }

    // MARK: - Private label

    @ViewBuilder
    private var label: some View {
        HStack(spacing: iconSpacing) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(labelColor)
                    .scaleEffect(size == .big ? 1.0 : 0.75)
            } else {
                if let icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                        .foregroundStyle(labelColor)
                }

                Text(title)
                    .font(titleFont)
                    .tracking(titleTracking)
                    .foregroundStyle(labelColor)
            }
        }
        .frame(maxWidth: maxWidth, minHeight: height)
    }

    // MARK: - Helpers

    private var height: CGFloat {
        switch size {
        case .big:   return 52
        case .small: return 32
        }
    }

    private var maxWidth: CGFloat? {
        switch size {
        case .big:   return .infinity
        case .small: return nil
        }
    }

    private var titleFont: Font {
        switch size {
        case .big:
            switch style {
            case .primary:              return .App.headline          // Medium / 17
            case .secondary(let outlined):
                return outlined ? .App.headline : .App.body           // outlined → Medium / 17, ghost → Regular / 17
            }
        case .small:
            return .App.subheadline                                   // Regular / 15
        }
    }

    private var titleTracking: CGFloat {
        switch size {
        case .big:   return 0
        case .small: return CGFloat.Tracking.subheadline              // -0.24
        }
    }

    private var labelColor: Color {
        switch style {
        case .primary:     return .App.white
        case .secondary:   return .App.brown1
        }
    }

    private var iconSize: CGFloat {
        switch size {
        case .big:   return 32
        case .small: return 24
        }
    }

    private var iconSpacing: CGFloat {
        switch size {
        case .big:   return CGFloat.Spacing.sm
        case .small: return CGFloat.Spacing.xs
        }
    }
}

// MARK: - ButtonStyle

private struct AppButtonStyle: ButtonStyle {

    let style: AppButton.Style
    let size: AppButton.Size
    let isDisabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, horizontalPadding)
            .background(background(pressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(stroke(pressed: configuration.isPressed))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    // MARK: - Helpers

    private var horizontalPadding: CGFloat {
        switch size {
        case .big:   return CGFloat.Spacing.lg      // 24
        case .small: return CGFloat.Spacing.md      // 16
        }
    }

    private func background(pressed: Bool) -> some View {
        Group {
            switch style {
            case .primary:
                Color.App.brown1
                    .opacity(isDisabled ? 0.3 : (pressed ? 0.85 : 1.0))
            case .secondary:
                Color.App.white
                    .opacity(isDisabled ? 0.3 : (pressed ? 0.85 : 1.0))
            }
        }
    }

    @ViewBuilder
    private func stroke(pressed: Bool) -> some View {
        switch style {
        case .primary:
            EmptyView()
        case .secondary(let outlined):
            if outlined {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.App.brown1, lineWidth: 1)
            } else {
                EmptyView()
            }
        }
    }
}

// MARK: - Convenience initialisers

extension AppButton {

    /// Primary big button
    init(title: String, action: @escaping () -> Void) {
        self.init(title: title, style: .primary, size: .big, action: action)
    }

    /// Secondary outlined big button
    static func secondaryOutlined(
        title: String,
        size: Size = .big,
        icon: Image? = nil,
        action: @escaping () -> Void
    ) -> AppButton {
        AppButton(title: title, style: .secondary(outlined: true), size: size, icon: icon, action: action)
    }

    /// Secondary ghost (no border) button
    static func secondaryGhost(
        title: String,
        size: Size = .big,
        icon: Image? = nil,
        action: @escaping () -> Void
    ) -> AppButton {
        AppButton(title: title, style: .secondary(outlined: false), size: size, icon: icon, action: action)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("All variants") {
    ScrollView {
        VStack(spacing: CGFloat.Spacing.md) {
            Text("Big buttons").font(.App.headline).padding(.top)

            AppButton(title: "Primary") {}

            AppButton.secondaryOutlined(title: "Secondary outlined") {}

            AppButton.secondaryGhost(title: "Secondary ghost") {}

            AppButton(
                title: "With icon",
                style: .primary,
                size: .big,
                icon: Image(systemName: "envelope")
            ) {}

            AppButton(title: "Loading", isLoading: true) {}

            AppButton(title: "Disabled", isDisabled: true) {}

            Divider()
            Text("Small buttons").font(.App.headline)

            HStack(spacing: CGFloat.Spacing.sm) {
                AppButton(title: "Primary", style: .primary, size: .small) {}
                AppButton.secondaryOutlined(title: "Outlined", size: .small) {}
            }

            HStack(spacing: CGFloat.Spacing.sm) {
                AppButton(
                    title: "Icon",
                    style: .primary,
                    size: .small,
                    icon: Image(systemName: "envelope")
                ) {}
                AppButton.secondaryGhost(
                    title: "Ghost",
                    size: .small,
                    icon: Image(systemName: "star")
                ) {}
            }
        }
        .padding(.horizontal, CGFloat.Spacing.md)
        .padding(.bottom, CGFloat.Spacing.xl)
    }
    .background(Color.App.backgroundLight)
}
#endif
