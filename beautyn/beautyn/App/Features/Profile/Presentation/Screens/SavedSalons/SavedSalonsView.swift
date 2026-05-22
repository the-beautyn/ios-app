import SwiftUI

// MARK: - SavedSalonsView

struct SavedSalonsView: BaseViewProtocol {

    @StateObject var viewModel: SavedSalonsViewModel

    var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            title
            searchField
                .padding(.horizontal, CGFloat.Spacing.md)
                .padding(.bottom, CGFloat.Spacing.md)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.App.backgroundLight)
    }

    // MARK: - Title

    private var title: some View {
        Text(Localization.savedSalonsTitle)
            .font(.App.title1Medium)
            .tracking(CGFloat.Tracking.title1)
            .foregroundStyle(Color.App.text)
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.lg)
    }

    // MARK: - Search

    private var searchField: some View {
        HStack(spacing: CGFloat.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(Color.App.gray2)

            TextField(
                Localization.savedSalonsSearchPlaceholder,
                text: $viewModel.searchText
            )
            .font(.App.footnote)
            .foregroundStyle(Color.App.text)
            .tint(Color.App.brown1)
            .submitLabel(.search)
        }
        .padding(.horizontal, 14)
        .frame(height: 50)
        .overlay {
            Capsule().stroke(Color.App.blueTransparency, lineWidth: 1)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.items.isEmpty && !viewModel.isLoading {
            emptyState
        } else {
            list
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: CGFloat.Spacing.md) {
                ForEach(viewModel.items) { salon in
                    SalonCardView(
                        salon: salon,
                        style: .fullWidth,
                        onTap: { viewModel.didTapSalon(salonId: salon.id) },
                        onFavoriteTap: { viewModel.didTapFavorite(salonId: salon.id) }
                    )
                }
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.lg)
        }
    }

    private var emptyState: some View {
        Text(Localization.savedSalonsEmpty)
            .font(.App.body)
            .foregroundStyle(Color.App.gray)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, CGFloat.Spacing.lg)
    }
}
