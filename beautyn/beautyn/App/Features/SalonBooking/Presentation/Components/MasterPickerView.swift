import SwiftUI

// MARK: - MasterModel

struct MasterModel: Identifiable {
    let id: String
    let name: String
    let imageURL: URL?
}

// MARK: - MasterPickerView
//
// Matches Figma master avatar picker in the booking date/time screen.
// Horizontal scroll of circular avatars with a name label below.
// First item is always "Будь-який" (Any master).

struct MasterPickerView: View {

    let masters: [MasterModel]
    @Binding var selectedMasterId: String?

    private let avatarSize: CGFloat = 52

    var body: some View {
        // "Будь-який" + the hairline stay pinned at the leading edge; only the
        // specialist avatars to the right of the divider scroll horizontally.
        HStack(spacing: CGFloat.Spacing.md) {
            masterItem(
                id: nil,
                name: Localization.bookingAnyMaster,
                imageURL: nil
            )

            if !masters.isEmpty {
                Rectangle()
                    .fill(Color.App.blueTransparency)
                    .frame(width: 1, height: 40)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: CGFloat.Spacing.md) {
                        ForEach(masters) { master in
                            masterItem(id: master.id, name: master.name, imageURL: master.imageURL)
                        }
                    }
                    .padding(.trailing, CGFloat.Spacing.md)
                }
            }
        }
        .padding(.leading, CGFloat.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func masterItem(id: String?, name: String, imageURL: URL?) -> some View {
        let isSelected = selectedMasterId == id

        Button {
            selectedMasterId = id
        } label: {
            VStack(spacing: CGFloat.Spacing.xs) {
                ZStack {
                    CachedImage.avatar(
                        url: imageURL,
                        size: CGSize(width: avatarSize, height: avatarSize)
                    )

                    if isSelected {
                        // strokeBorder (not stroke) keeps the ring inside its frame,
                        // otherwise the outer half overflows the bounds and the enclosing
                        // ScrollView clips it (~1px) at the top edge.
                        Circle()
                            .strokeBorder(Color.App.sage, lineWidth: 3)
                            .frame(width: avatarSize + 6, height: avatarSize + 6)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if isSelected { selectedBadge }
                }

                Text(name)
                    .font(.App.caption2)
                    .tracking(CGFloat.Tracking.caption2)
                    .foregroundStyle(Color.App.gray)
                    .lineLimit(1)
                    .frame(width: avatarSize + 8)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    // Sage checkmark badge on the selected avatar's lower-trailing edge. The
    // white circle behind shows through the symbol's cut-out check and gives a
    // thin halo so it reads on any photo.
    private var selectedBadge: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(Color.App.sage)
            .background(Circle().fill(Color.App.white))
    }
}

// MARK: - Preview

#if DEBUG
private let previewMasters: [MasterModel] = [
    .init(id: "1", name: "Ashley", imageURL: nil),
    .init(id: "2", name: "Amber", imageURL: nil),
    .init(id: "3", name: "Ashley", imageURL: nil),
    .init(id: "4", name: "Amber", imageURL: nil),
]

#Preview {
    @Previewable @State var selected: String? = nil
    MasterPickerView(masters: previewMasters, selectedMasterId: $selected)
        .padding(.vertical, CGFloat.Spacing.md)
}
#endif
