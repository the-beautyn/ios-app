import SwiftUI

// MARK: - SearchSortView
//
// Sort & price filter sheet (Figma 143:8873) — ✕ toolbar, "Сортувати за"
// radio list, "Прайс" max-price slider, and an Очистити / Застосувати bar
// pinned to the bottom. Drawn with the in-house AppBottomSheet (fixed
// height, anchored to the screen bottom) inside a transparent full-screen
// container — the system pageSheet floats partial-height sheets on iOS 26,
// which doesn't match the design.

struct SearchSortView: BaseViewProtocol {

    @StateObject var viewModel: SearchSortViewModel

    /// Static sheet height: toolbar + four sort rows + price section +
    /// buttons bar + home-indicator clearance, per the Figma layout.
    private static let sheetHeight: CGFloat = 480

    var contentView: some View {
        Color.clear
            .bottomSheet(
                isPresented: $viewModel.isSheetPresented,
                style: .fixed(height: Self.sheetHeight),
                showDragHandle: false,
                isDismissible: true
            ) {
                sheetBody
            }
    }

    private var sheetBody: some View {
        VStack(spacing: 0) {
            toolbar

            VStack(spacing: CGFloat.Spacing.xl) {
                sortSection
                priceSection
            }

            Spacer(minLength: 0)

            buttonsBar
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack {
            Spacer()

            Button(action: { viewModel.didTapClose() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.App.gray)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.App.gray.opacity(0.08)))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, CGFloat.Spacing.md)
        .padding(.top, CGFloat.Spacing.md)
        .padding(.bottom, CGFloat.Spacing.sm + 2)
    }

    // MARK: - Sort section

    private var sortSection: some View {
        VStack(spacing: 0) {
            sectionHeader(Localization.searchSortSection)

            ForEach(viewModel.sortOptions, id: \.self) { option in
                sortRow(option)
            }
        }
    }

    private func sortRow(_ option: SearchSortOption) -> some View {
        Button(action: { viewModel.didSelectSort(option) }) {
            HStack {
                Text(title(for: option))
                    .font(.App.footnote)
                    .foregroundStyle(Color.App.text)

                Spacer()

                radioIndicator(isSelected: viewModel.selectedSort == option)
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.vertical, CGFloat.Spacing.sm + 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func radioIndicator(isSelected: Bool) -> some View {
        if isSelected {
            // White center + thick ring, per Figma; strokeBorder keeps the
            // ring inside the 16pt frame so nothing gets shaved by clipping.
            Circle()
                .strokeBorder(Color.App.brown2, lineWidth: 4.5)
                .background(Circle().fill(Color.App.white))
                .frame(width: 16, height: 16)
        } else {
            Circle()
                .fill(Color.App.beige2)
                .frame(width: 16, height: 16)
        }
    }

    // MARK: - Price section

    private var priceSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text(Localization.searchPriceSection)
                    .font(.App.footnoteSemibold)
                    .foregroundStyle(Color.App.text)

                Spacer()

                Text(Localization.priceUAH("\(Int(viewModel.priceLowerValue)) – \(Int(viewModel.priceUpperValue))"))
                    .font(.App.footnote)
                    .foregroundStyle(Color.App.text)
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.vertical, CGFloat.Spacing.xs)

            AppRangeSlider(
                lowerValue: $viewModel.priceLowerValue,
                upperValue: $viewModel.priceUpperValue,
                bounds: viewModel.priceLowerBound...viewModel.priceUpperBound,
                step: SearchSortViewModel.priceStep
            )
            .padding(.horizontal, CGFloat.Spacing.md)
        }
    }

    // MARK: - Bottom bar

    private var buttonsBar: some View {
        HStack(spacing: CGFloat.Spacing.sm + 4) {
            AppButton.secondaryOutlined(title: Localization.searchSortClear) {
                viewModel.didTapClear()
            }
            AppButton(title: Localization.searchSortApply) {
                viewModel.didTapApply()
            }
        }
        .padding(.horizontal, CGFloat.Spacing.md)
        .padding(.top, CGFloat.Spacing.md)
        // The sheet ignores safe areas (anchored to the screen edge), so the
        // home-indicator clearance is part of the bar itself.
        .padding(.bottom, CGFloat.Spacing.xl)
        .overlay(alignment: .top) {
            // The hairline alone separates the bar from the content — the
            // background stays the sheet's own white.
            Color.App.blueTransparency
                .frame(height: 1)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.App.footnoteSemibold)
                .foregroundStyle(Color.App.text)

            Spacer()
        }
        .padding(.horizontal, CGFloat.Spacing.md)
        .padding(.vertical, CGFloat.Spacing.xs)
    }

    private func title(for option: SearchSortOption) -> String {
        switch option {
        case .ratingDesc:
            return Localization.searchSortByRating
        case .popular:
            return Localization.searchSortByPopularity
        case .distance:
            return Localization.searchSortByDistance
        case .priceAsc, .priceDesc:
            return Localization.searchSortByPrice
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    SearchSortView(
        viewModel: SearchSortViewModel(
            transition: .init(didTapClose: {}),
            context: SearchSortContext(
                initialSort: .popular,
                initialPriceMin: nil,
                initialPriceMax: nil,
                filterOptions: SearchFilterOptions(
                    sortOptions: [.distance, .ratingDesc, .priceAsc, .priceDesc, .popular],
                    minPrice: 100,
                    maxPrice: 1_150
                ),
                onApply: { _ in }
            )
        )
    )
}
#endif
