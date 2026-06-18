import SwiftUI

// MARK: - SelectServiceRow
//
// Card-style service row for the SelectService screen, matching Figma 143:3341:
// a white rounded card (radius 16) with a blue-transparency border and 12pt
// padding. Tapping the trailing control toggles the service in/out of the
// basket — outlined "Додати" (clay-rose) → brown filled checkmark.
//
// Distinct from the shared `ServiceRowView` (divider rows on SalonProfile);
// kept separate so this card styling stays scoped to SelectService.

struct SelectServiceRow: View {

    let service: ServiceModel
    var isLoading: Bool = false
    var onToggle: () -> Void

    // Figma uses 12pt for the card padding, content spacing and price/duration
    // gap — between the .sm (8) and .md (16) tokens.
    private let gap: CGFloat = CGFloat.Spacing.sm + CGFloat.Spacing.xs   // 12
    private let thumbnailSize: CGFloat = 32

    var body: some View {
        VStack(alignment: .leading, spacing: gap) {
            VStack(alignment: .leading, spacing: CGFloat.Spacing.xxs) {
                Text(service.name)
                    .font(.App.subheadline)
                    .foregroundStyle(Color.App.brown1)

                if !service.description.isEmpty {
                    Text(service.description)
                        .font(.App.caption1)
                        .foregroundStyle(Color.App.gray2)
                        .lineLimit(2)
                }
            }

            if !service.photoURLs.isEmpty {
                HStack(spacing: CGFloat.Spacing.sm) {
                    ForEach(service.photoURLs.prefix(3), id: \.self) { url in
                        CachedImage(
                            url: url,
                            size: CGSize(width: thumbnailSize, height: thumbnailSize),
                            clipShape: RoundedRectangle(cornerRadius: 8, style: .continuous)
                        )
                    }
                }
            }

            HStack(alignment: .bottom) {
                HStack(spacing: gap) {
                    Text(service.price)
                        .font(.App.caption1)
                        .foregroundStyle(Color.App.brown1)

                    Text(service.duration)
                        .font(.App.caption1)
                        .foregroundStyle(Color.App.gray2)
                }

                Spacer(minLength: CGFloat.Spacing.sm)

                actionButton
            }
        }
        .padding(gap)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.App.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.App.blueTransparency, lineWidth: 1)
        )
    }

    // MARK: - Action button

    // One fixed-size control for both states: the "Додати" label and the
    // checkmark are always laid out (toggled via opacity), so the control — and
    // therefore the card — never changes size. The state change is animated, so
    // tapping crossfades the outlined "Додати" into the filled checkmark.
    private var actionButton: some View {
        Button(action: onToggle) {
            ZStack {
                Text(Localization.addButton)
                    .font(.App.subheadline)
                    .opacity(service.isAdded || isLoading ? 0 : 1)

                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .semibold))
                    .opacity(service.isAdded && !isLoading ? 1 : 0)

                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(service.isAdded ? Color.App.white : Color.App.brown2)
                }
            }
            .foregroundStyle(service.isAdded ? Color.App.white : Color.App.brown2)
            .padding(.horizontal, CGFloat.Spacing.sm + CGFloat.Spacing.xs)   // px-12
            .frame(height: 32)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(service.isAdded ? Color.App.brown1 : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(service.isAdded ? Color.clear : Color.App.brown2, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.2), value: service.isAdded)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    VStack(spacing: CGFloat.Spacing.sm + CGFloat.Spacing.xs) {
        SelectServiceRow(
            service: ServiceModel(
                id: "1", name: "Classic Manicure",
                description: "Охайна форма, кутикула, легкий саге та базове покриття.",
                photoURLs: [], price: "від 700 грн", duration: "90 хв.", isAdded: false
            ),
            onToggle: {}
        )
        SelectServiceRow(
            service: ServiceModel(
                id: "2", name: "Ear wax removal",
                description: "", photoURLs: [], price: "від 350 грн", duration: "60 хв.", isAdded: true
            ),
            onToggle: {}
        )
    }
    .padding(CGFloat.Spacing.md)
    .background(Color.App.white)
}
#endif
