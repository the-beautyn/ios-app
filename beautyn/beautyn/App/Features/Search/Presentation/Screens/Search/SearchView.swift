import SwiftUI
import Combine

// MARK: - SearchView
//
// Matches Figma "Search" (143:8526) — the text-search sheet: focused search
// field, location + date pills, "Попередній пошук" history (swipe-to-delete,
// Очистити) and live "Салони" suggestions. Scrolling the list hides the
// keyboard interactively.

struct SearchView: BaseViewProtocol {

    @StateObject var viewModel: SearchViewModel
    /// Render tests pass `false` — the harness has no keyboard and the 50ms
    /// focus hop only adds nondeterminism to snapshots.
    var autoFocusesSearchField: Bool = true

    @FocusState private var isSearchFocused: Bool

    var contentView: some View {
        VStack(spacing: 0) {
            SearchSheetHeaderView(
                icon: "xmark",
                title: Localization.tabSearch,
                onButtonTap: { viewModel.didTapClose() }
            )

            fieldsBlock
                .padding(.horizontal, CGFloat.Spacing.md)
                .padding(.top, CGFloat.Spacing.sm)

            // Fields block → first section header = 32pt per Figma; the List
            // contributes ~28pt itself (header inset + implicit spacing).
            resultsList
                .padding(.top, CGFloat.Spacing.xs)
        }
        .background(Color.App.white)
        .task {
            guard autoFocusesSearchField else { return }
            // Sheet presentation needs a runloop tick before @FocusState
            // sticks; without the delay the keyboard sometimes doesn't appear.
            try? await Task.sleep(for: .milliseconds(50))
            isSearchFocused = true
        }
    }

    // MARK: - Fields

    private var fieldsBlock: some View {
        VStack(spacing: CGFloat.Spacing.sm + 4) {
            SearchBorderedField(
                placeholder: Localization.searchHint,
                text: $viewModel.query,
                isFocused: $isSearchFocused,
                onSubmit: { viewModel.didSubmit() }
            )

            HStack(spacing: CGFloat.Spacing.sm + 4) {
                SearchPillButton(
                    icon: Image(systemName: "location.fill"),
                    title: viewModel.locationTitle,
                    onTap: { viewModel.didTapLocationField() }
                )
                SearchPillButton(
                    icon: Image(systemName: "calendar"),
                    title: viewModel.dateTitle,
                    onTap: { viewModel.didTapDateField() }
                )
            }
        }
    }

    // MARK: - Results

    private var resultsList: some View {
        List {
            if viewModel.showsHistorySection {
                Section {
                    ForEach(viewModel.historyRows) { row in
                        salonRow(row) {
                            viewModel.didTapHistoryRow(row)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteHistoryRow(row)
                            } label: {
                                Text(Localization.commonDelete)
                            }
                        }
                    }
                } header: {
                    historyHeader
                }
            }

            if viewModel.showsResultsSection {
                Section {
                    ForEach(viewModel.resultRows) { row in
                        salonRow(row) {
                            viewModel.didTapResultRow(row)
                        }
                    }
                } header: {
                    sectionHeader(Localization.searchSalonsSection)
                }
            }
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.interactively)
    }

    private var historyHeader: some View {
        HStack {
            Text(Localization.searchPreviousSection)
                .font(.App.callout)
                .foregroundStyle(Color.App.text)

            Spacer()

            Button(Localization.searchClearHistory) {
                viewModel.didTapClearHistory()
            }
            .font(.App.caption2)
            .foregroundStyle(Color.App.brown2)
            .buttonStyle(.plain)
        }
        .modifier(SectionHeaderChrome())
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.App.callout)
            .foregroundStyle(Color.App.text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(SectionHeaderChrome())
    }

    private func salonRow(
        _ row: SearchViewModel.Row,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack(spacing: CGFloat.Spacing.sm) {
                CachedImage(
                    url: row.imageUrl.flatMap(URL.init(string:)),
                    size: CGSize(width: 52, height: 52),
                    clipShape: Circle()
                )

                VStack(alignment: .leading, spacing: CGFloat.Spacing.xxs) {
                    Text(row.title)
                        .font(.App.body)
                        .foregroundStyle(Color.App.text)
                        .lineLimit(1)

                    // Design shows the name only; the address disambiguates
                    // same-name salons in the typed results.
                    if let subtitle = row.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.App.caption1)
                            .foregroundStyle(Color.App.gray2)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowSeparator(.hidden)
        .listRowInsets(Self.rowInsets)
    }

    // Figma: rows are 52pt tall with 8pt gaps at a 16pt edge inset.
    private static let rowInsets = EdgeInsets(
        top: CGFloat.Spacing.xs,
        leading: CGFloat.Spacing.md,
        bottom: CGFloat.Spacing.xs,
        trailing: CGFloat.Spacing.md
    )
}

// MARK: - SectionHeaderChrome

/// Pinned section headers get a translucent material backdrop by default —
/// rows scrolling underneath show through blurred. Zero insets + an opaque
/// full-width white background keep the header solid.
private struct SectionHeaderChrome: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.vertical, CGFloat.Spacing.xs)
            .frame(maxWidth: .infinity)
            .background(Color.App.white)
            .listRowInsets(EdgeInsets())
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    SearchView(
        viewModel: SearchViewModel(
            transition: .init(
                didTapClose: {},
                didTapLocationField: { _ in },
                didTapDateField: { _, _ in },
                didSelectSalon: { _, _ in },
                didSubmit: { _ in }
            ),
            initialQuery: nil,
            initialLocation: nil,
            initialDate: nil,
            mapCenter: GeoPoint(latitude: 50.4501, longitude: 30.5234),
            getSearchHistoryUseCase: PreviewGetSearchHistoryUseCase(),
            clearSearchHistoryUseCase: PreviewClearSearchHistoryUseCase(),
            deleteSearchHistoryItemUseCase: PreviewDeleteSearchHistoryItemUseCase(),
            searchSalonsUseCase: PreviewSheetSearchSalonsUseCase(),
            sessionManager: SessionManager(keychainService: KeychainServiceImpl(), defaultsService: DefaultsStorageService())
        ),
        autoFocusesSearchField: false
    )
}

private final class PreviewGetSearchHistoryUseCase: GetSearchHistoryUseCase {
    func execute(limit: Int) async throws -> [SearchHistoryItem] {
        [
            SearchHistoryItem(id: "h1", salonId: "s1", name: "Yala Spa", city: "Київ", imageUrl: nil, point: GeoPoint(latitude: 50.4501, longitude: 30.5234)),
            SearchHistoryItem(id: "h2", salonId: "s2", name: "Nail bar: Glossy Room", city: "Київ", imageUrl: nil, point: GeoPoint(latitude: 50.4501, longitude: 30.5234))
        ]
    }
}

private final class PreviewClearSearchHistoryUseCase: ClearSearchHistoryUseCase {
    func execute() async throws {}
}

private final class PreviewDeleteSearchHistoryItemUseCase: DeleteSearchHistoryItemUseCase {
    func execute(id: String) async throws {}
}

private final class PreviewSheetSearchSalonsUseCase: SearchSalonsUseCase {
    func execute(_ query: SearchQuery) async throws -> SearchResults {
        let salons = [
            SearchSalon(id: "s3", name: "Clipse Manicure", address: "вул. Хрещатик, 22", rating: 4.8, distanceKm: 1.2, imageUrl: nil, latitude: 50.447, longitude: 30.524, isSaved: false),
            SearchSalon(id: "s4", name: "G-bar", address: "вул. Франка, 10", rating: 4.6, distanceKm: 2.0, imageUrl: nil, latitude: 50.453, longitude: 30.529, isSaved: false)
        ]
        return SearchResults(items: salons, page: 1, limit: 10, total: 2)
    }
}
#endif
