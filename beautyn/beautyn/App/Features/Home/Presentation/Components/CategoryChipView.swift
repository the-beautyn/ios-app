import SwiftUI

// MARK: - CategoryChipModel

struct CategoryChipModel: Identifiable {
    let id: String
    let title: String
    let imageURL: URL?
}

// MARK: - CategoryChipView
//
// Matches Figma category row on Home screen.
// Circular image (60 pt) with a label below.
// e.g. "Манікюрні салони", "Перукарні", "Масажні салони"

struct CategoryChipView: View {

    let category: CategoryChipModel
    let onTap: () -> Void

    private let imageSize: CGFloat = 60

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: CGFloat.Spacing.xs) {
                CachedImage(
                    url: category.imageURL,
                    size: CGSize(width: imageSize, height: imageSize),
                    clipShape: Circle(),
                    placeholder: AnyView(
                        SwiftUI.Image(.categoryPlaceholder)
                            .resizable()
                            .scaledToFill()
                    )
                )

                Text(category.title)
                    .font(.App.caption2)
                    .tracking(CGFloat.Tracking.caption2)
                    .foregroundStyle(Color.App.text)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: imageSize + 8, alignment: .top)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#if DEBUG
private let previewCategories: [CategoryChipModel] = [
    .init(id: "1", title: "Манікюрні салони", imageURL: nil),
    .init(id: "2", title: "Перукарні", imageURL: nil),
    .init(id: "3", title: "Масажні салони", imageURL: nil),
    .init(id: "4", title: "Косметологія", imageURL: nil),
]

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: CGFloat.Spacing.md) {
            ForEach(previewCategories) { category in
                CategoryChipView(category: category, onTap: {})
            }
        }
        .padding(.horizontal, CGFloat.Spacing.md)
    }
}
#endif
