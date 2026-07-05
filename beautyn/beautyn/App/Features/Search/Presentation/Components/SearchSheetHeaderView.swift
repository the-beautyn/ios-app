import SwiftUI

// MARK: - SearchSheetHeaderView
//
// Inline toolbar for the search modal screens (Figma 143:8533 / 143:8593) —
// a 44pt round leading button (✕ on the root, ← on pushed pages) with the
// title centered. The modal nav bar is hidden, so each screen draws this.

struct SearchSheetHeaderView: View {

    let icon: String
    let title: String
    let onButtonTap: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.App.headline)
                .foregroundStyle(Color.App.text)

            HStack {
                Button(action: onButtonTap) {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.App.gray)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.App.gray.opacity(0.08)))
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .padding(.horizontal, CGFloat.Spacing.md)
        // Grabber zone above + toolbar bottom inset, per Figma sheet chrome.
        .padding(.top, CGFloat.Spacing.md)
        .padding(.bottom, CGFloat.Spacing.sm + 2)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    VStack {
        SearchSheetHeaderView(icon: "xmark", title: "Пошук", onButtonTap: {})
        SearchSheetHeaderView(icon: "chevron.left", title: "Локація", onButtonTap: {})
        Spacer()
    }
}
#endif
