import SwiftUI

// MARK: - ServiceTypeFilterView
//
// Matches Figma "Search" (143:8965) — the service-type filter sheet: a
// radio-style single-select category list with a pinned Очистити /
// Застосувати bar at the bottom.

struct ServiceTypeFilterView: BaseViewProtocol {

    @StateObject var viewModel: ServiceTypeFilterViewModel

    var contentView: some View {
        VStack(spacing: 0) {
            SearchSheetHeaderView(
                icon: "xmark",
                title: Localization.searchFilterCategoryTitle,
                onButtonTap: { viewModel.didTapClose() }
            )

            categoriesList
        }
        .background(Color.App.white)
        .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
    }

    // MARK: - Categories

    private var categoriesList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.categories) { category in
                    categoryRow(category)
                }
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.vertical, CGFloat.Spacing.sm)
        }
    }

    private func categoryRow(_ category: AppCategory) -> some View {
        Button {
            viewModel.didTapCategory(category)
        } label: {
            HStack(spacing: CGFloat.Spacing.md) {
                radioCircle(isSelected: viewModel.selectedCategory?.id == category.id)

                Text(category.name)
                    .font(.App.body)
                    .foregroundStyle(Color.App.text)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
            .frame(height: Self.rowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func radioCircle(isSelected: Bool) -> some View {
        if isSelected {
            Circle()
                .fill(Color.App.brown2)
                .frame(width: Self.radioSize, height: Self.radioSize)
                .overlay(
                    // Figma: system edit-circle checkmark, SF Semibold 14.5.
                    Image(systemName: "checkmark")
                        .font(.system(size: 14.5, weight: .semibold))
                        .foregroundStyle(Color.App.white)
                )
        } else {
            Circle()
                .strokeBorder(Color.App.gray3, lineWidth: 1.5)
                .frame(width: Self.radioSize, height: Self.radioSize)
        }
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        HStack(spacing: CGFloat.Spacing.sm + 4) {
            AppButton.secondaryOutlined(title: Localization.searchFilterClear) {
                viewModel.didTapClear()
            }

            AppButton(title: Localization.searchFilterApply) {
                viewModel.didTapApply()
            }
        }
        .padding(.horizontal, CGFloat.Spacing.md)
        .padding(.top, CGFloat.Spacing.md)
        .padding(.bottom, CGFloat.Spacing.sm)
        .background(Color.App.white)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.App.blueTransparency)
                .frame(height: 1)
        }
    }

    // Figma: 52pt rows with a 22pt selection circle.
    private static let rowHeight: CGFloat = 52
    private static let radioSize: CGFloat = 22
}

// MARK: - Preview

#if DEBUG
#Preview {
    ServiceTypeFilterView(
        viewModel: ServiceTypeFilterViewModel(
            transition: .init(didTapClose: {}),
            context: ServiceTypeFilterContext(
                initialCategory: AppCategory(id: "c1", slug: "nails", name: "Нігті", imageUrl: nil, sortOrder: 1),
                onApply: { _ in }
            ),
            getAppCategoriesUseCase: PreviewGetAppCategoriesUseCase()
        )
    )
}

private final class PreviewGetAppCategoriesUseCase: GetAppCategoriesUseCase {
    func execute() async throws -> [AppCategory] {
        [
            AppCategory(id: "c1", slug: "nails", name: "Нігті", imageUrl: nil, sortOrder: 1),
            AppCategory(id: "c2", slug: "hair", name: "Волосся", imageUrl: nil, sortOrder: 2),
            AppCategory(id: "c3", slug: "face", name: "Обличчя", imageUrl: nil, sortOrder: 3),
            AppCategory(id: "c4", slug: "brows-lashes", name: "Брови й вії", imageUrl: nil, sortOrder: 4),
            AppCategory(id: "c5", slug: "makeup", name: "Макіяж", imageUrl: nil, sortOrder: 5),
            AppCategory(id: "c6", slug: "epilation", name: "Епіляція", imageUrl: nil, sortOrder: 6),
            AppCategory(id: "c7", slug: "spa-massage", name: "SPA/Масаж", imageUrl: nil, sortOrder: 7),
            AppCategory(id: "c8", slug: "injections", name: "Інʼєкції", imageUrl: nil, sortOrder: 8),
            AppCategory(id: "c9", slug: "trichology", name: "Трихологія", imageUrl: nil, sortOrder: 9),
            AppCategory(id: "c10", slug: "for-men", name: "Для чоловіків", imageUrl: nil, sortOrder: 10),
            AppCategory(id: "c11", slug: "other", name: "Інше", imageUrl: nil, sortOrder: 11)
        ]
    }
}
#endif
