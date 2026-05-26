import SwiftUI

// MARK: - GlassCircleButton
//
// iOS 26 Liquid Glass circular button used over photographic backgrounds
// (cover image headers, full-bleed media). Uses the native `.glassEffect`
// modifier — when two of these sit inside a `GlassEffectContainer`, the
// system fluidly merges their backgrounds into one glass surface.

struct GlassCircleButton: View {

    let icon: Image
    var diameter: CGFloat = 44
    var iconSize: CGFloat = 16
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .fontWeight(.medium)
                .foregroundStyle(Color.App.text)
                .frame(width: diameter, height: diameter)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: Circle())
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    ZStack {
        LinearGradient(
            colors: [Color.App.brown1, Color.App.beige2],
            startPoint: .top,
            endPoint: .bottom
        )
        VStack(spacing: CGFloat.Spacing.lg) {
            GlassCircleButton(icon: Image(systemName: "chevron.left"), action: {})

            GlassEffectContainer(spacing: 4) {
                HStack(spacing: 4) {
                    GlassCircleButton(icon: Image(systemName: "square.and.arrow.up"), action: {})
                    GlassCircleButton(icon: Image(systemName: "heart"), action: {})
                }
            }
        }
    }
    .ignoresSafeArea()
}
#endif
