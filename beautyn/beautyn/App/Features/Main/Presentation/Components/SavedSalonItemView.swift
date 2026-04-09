import SwiftUI

// MARK: - SavedSalonUI

struct SavedSalonUI: Identifiable {
    let id: String
    let salonName: String
    let imageURL: URL?
}

// MARK: - SavedSalonItemView
//
// Matches Figma "SavedItem" — 100×100 rounded-rect image with salon name below.
// Used in the horizontal "Збереженні 🩷" section on the Home screen.

struct SavedSalonItemView: View {

    let salon: SavedSalonUI
    var onTap: () -> Void

    private let imageSize: CGFloat = 100
    private let cornerRadius: CGFloat = 16

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: CGFloat.Spacing.sm) {
                CachedImage(
                    url: salon.imageURL,
                    size: CGSize(width: imageSize, height: imageSize),
                    clipShape: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.App.brown1.opacity(0.2))
                )

                Text(salon.salonName)
                    .font(.App.caption2)
                    .tracking(CGFloat.Tracking.caption2)
                    .foregroundStyle(Color.App.brown1)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: imageSize)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: CGFloat.Spacing.sm) {
            ForEach(0..<4) { i in
                SavedSalonItemView(
                    salon: SavedSalonUI(id: "\(i)", salonName: "Nail bar: Glossy Room", imageURL: nil),
                    onTap: {}
                )
            }
        }
        .padding(.horizontal, CGFloat.Spacing.md)
    }
}
#endif
