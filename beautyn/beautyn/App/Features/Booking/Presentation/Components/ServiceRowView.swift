import SwiftUI

// MARK: - ServiceModel

struct ServiceModel: Identifiable {
    let id: String
    let name: String
    let description: String
    let photoURLs: [URL]
    let price: String       // e.g. "від 700 грн"
    let duration: String    // e.g. "90 хв."
    var isAdded: Bool = false
}

// MARK: - ServiceRowView
//
// Matches Figma service row on the Salon Profile "Послуги" tab.
// Name + description + photo thumbnails row + price/duration + "Додати" button.

struct ServiceRowView: View {

    let service: ServiceModel
    var onAdd: () -> Void

    private let thumbnailSize: CGFloat = 36

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
            VStack(alignment: .leading, spacing: CGFloat.Spacing.xxs) {
                Text(service.name)
                    .font(.App.subheadline)
                    .foregroundStyle(Color.App.text)

                Text(service.description)
                    .font(.App.caption2)
                    .tracking(CGFloat.Tracking.caption2)
                    .foregroundStyle(Color.App.gray)
                    .lineLimit(2)
            }

            if !service.photoURLs.isEmpty {
                HStack(spacing: CGFloat.Spacing.xs) {
                    ForEach(service.photoURLs.prefix(3), id: \.self) { url in
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image): image.resizable().scaledToFill()
                            default: Color.App.beige2
                            }
                        }
                        .frame(width: thumbnailSize, height: thumbnailSize)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                }
            }

            HStack {
                HStack(spacing: CGFloat.Spacing.sm) {
                    Text(service.price)
                        .font(.App.caption1)
                        .foregroundStyle(Color.App.brown1)

                    Text(service.duration)
                        .font(.App.caption1)
                        .foregroundStyle(Color.App.gray.opacity(0.5))
                }

                Spacer()

                AppButton.secondaryOutlined(title: service.isAdded ? Localization.addedButton : Localization.addButton, size: .small, action: onAdd)
            }
        }
        .padding(.vertical, CGFloat.Spacing.sm)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

// MARK: - Preview

#if DEBUG
private let previewService = ServiceModel(
    id: "1",
    name: "Classic Manicure",
    description: "Охайна форма, кутикула, легкий саге та базове покриття.",
    photoURLs: [],
    price: "від 700 грн",
    duration: "90 хв."
)

#Preview {
    VStack(spacing: 0) {
        ServiceRowView(service: previewService, onAdd: {})
        ServiceRowView(service: ServiceModel(id: "2", name: "French Manicure", description: "Класичний французький манікюр.", photoURLs: [], price: "від 900 грн", duration: "120 хв.", isAdded: true), onAdd: {})
    }
    .padding(.horizontal, CGFloat.Spacing.md)
}
#endif
