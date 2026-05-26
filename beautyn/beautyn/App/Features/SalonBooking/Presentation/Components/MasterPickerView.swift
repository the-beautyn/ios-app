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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CGFloat.Spacing.md) {
                masterItem(
                    id: nil,
                    name: Localization.bookingAnyMaster,
                    imageURL: nil
                )

                ForEach(masters) { master in
                    masterItem(id: master.id, name: master.name, imageURL: master.imageURL)
                }
            }
            .padding(.horizontal, CGFloat.Spacing.md)
        }
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
                        Circle()
                            .stroke(Color.App.brown1, lineWidth: 2)
                            .frame(width: avatarSize + 4, height: avatarSize + 4)
                    }
                }

                Text(name)
                    .font(.App.caption2)
                    .tracking(CGFloat.Tracking.caption2)
                    .foregroundStyle(Color.App.text)
                    .lineLimit(1)
                    .frame(width: avatarSize + 8)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
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
