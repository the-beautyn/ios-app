import SwiftUI

// MARK: - SalonCardModel

struct SalonCardModel: Identifiable {
    let id: String
    let name: String
    let address: String
    let imageURL: URL?
    let rating: Double?
    let tag: String?
    var isFavorited: Bool
}

// MARK: - SalonCardView
//
// Matches Figma "PopularItem" / "AvailableTodayItem" / "NearbyHairdresserItem" cards.
//
// Style.horizontal — 280 × 177 pt image, used in horizontal scroll sections on Home.
// Style.fullWidth  — full available width image, used in Search results list.

struct SalonCardView: View {

    enum Style {
        case horizontal
        case fullWidth
    }

    let salon: SalonCardModel
    var style: Style = .horizontal
    var onTap: () -> Void
    var onFavoriteTap: () -> Void

    private let imageHeight: CGFloat = 177
    private let cornerRadius: CGFloat = 16

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
                imageSection
                detailsSection
            }
        }
        .buttonStyle(.plain)
        .frame(width: style == .horizontal ? 280 : nil)
    }

    // MARK: - Image

    private var imageSection: some View {
        ZStack(alignment: .bottom) {
            Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: imageHeight)
            .overlay {
                CachedImage(
                    url: salon.imageURL,
                    size: CGSize(width: style == .horizontal ? 280 : 430, height: imageHeight),
                    clipShape: Rectangle()
                )
            }
            .overlay(Color.App.brown1.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

            // Badges overlay
            VStack {
                HStack(alignment: .top) {
                    if let tag = salon.tag {
                        TagBadgeView(text: tag)
                    }
                    Spacer()
                    if let rating = salon.rating {
                        RatingBadgeView(rating: rating)
                    }
                }
                .padding(.horizontal, CGFloat.Spacing.md)
                .padding(.top, CGFloat.Spacing.md)

                Spacer()

                HStack {
                    Spacer()
                    FavoriteButtonView(isFavorited: salon.isFavorited, onTap: onFavoriteTap)
                        .padding(.trailing, CGFloat.Spacing.sm)
                        .padding(.bottom, CGFloat.Spacing.sm)
                }
            }
            .frame(height: imageHeight)
        }
    }

    // MARK: - Details

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.xxs) {
            Text(salon.name)
                .font(.App.subheadline)
                .tracking(CGFloat.Tracking.subheadline)
                .foregroundStyle(Color.App.brown1)
                .lineLimit(1)

            Text(salon.address)
                .font(.App.caption2)
                .tracking(CGFloat.Tracking.caption2)
                .foregroundStyle(Color.App.gray)
                .lineLimit(1)
        }
    }
}

// MARK: - Preview

#if DEBUG
private let previewSalon = SalonCardModel(
    id: "1",
    name: "Nail bar: Glossy Room",
    address: "вул. Зеленицька, 15 (411), 05-091",
    imageURL: nil,
    rating: 4.5,
    tag: "Top 10 Masters",
    isFavorited: false
)

#Preview("Horizontal") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: CGFloat.Spacing.sm) {
            SalonCardView(salon: previewSalon, style: .horizontal, onTap: {}, onFavoriteTap: {})
            SalonCardView(salon: SalonCardModel(id: "2", name: "Beauty Studio", address: "вул. Франка, 10", imageURL: nil, rating: 5, tag: nil, isFavorited: true), style: .horizontal, onTap: {}, onFavoriteTap: {})
        }
        .padding(.horizontal, CGFloat.Spacing.md)
    }
}

#Preview("Full Width") {
    VStack(spacing: CGFloat.Spacing.sm) {
        SalonCardView(salon: previewSalon, style: .fullWidth, onTap: {}, onFavoriteTap: {})
        SalonCardView(salon: previewSalon, style: .fullWidth, onTap: {}, onFavoriteTap: {})
    }
    .padding(.horizontal, CGFloat.Spacing.md)
}
#endif
