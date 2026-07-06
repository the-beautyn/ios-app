import SwiftUI
import Combine

// MARK: - SearchLocationView
//
// Matches Figma "Локація" (143:8586) — pushed inside the search sheet:
// back-arrow toolbar, bordered address/city field (auto-focused), the
// "Моя геолокація" shortcut and the place results underneath.

struct SearchLocationView: BaseViewProtocol {

    @StateObject var viewModel: SearchLocationViewModel
    /// Render tests pass `false` — see `SearchView.autoFocusesSearchField`.
    var autoFocusesSearchField: Bool = true

    @FocusState private var isSearchFocused: Bool

    var contentView: some View {
        VStack(spacing: 0) {
            SearchSheetHeaderView(
                icon: "chevron.left",
                title: Localization.locationPickerTitle,
                onButtonTap: { viewModel.didTapBack() }
            )

            VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
                SearchBorderedField(
                    placeholder: Localization.locationPickerSearchPlaceholder,
                    text: $viewModel.query,
                    isFocused: $isSearchFocused
                )

                myLocationRow
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.sm)

            resultsList
        }
        .background(Color.App.white)
        .task {
            guard autoFocusesSearchField else { return }
            try? await Task.sleep(for: .milliseconds(50))
            isSearchFocused = true
        }
    }

    // MARK: - "Моя геолокація"

    private var myLocationRow: some View {
        Button(action: { viewModel.didTapMyLocation() }) {
            HStack(spacing: CGFloat.Spacing.xs + 2) {
                Image(systemName: "location.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.App.gray)

                Text(Localization.locationPickerMyGeolocation)
                    .font(.App.footnote)
                    .foregroundStyle(Color.App.gray)

                Spacer()

                if viewModel.isLocating {
                    ProgressView().progressViewStyle(.circular)
                }
            }
            // Figma 143:8606: plain row, 8pt vertical padding.
            .padding(.vertical, CGFloat.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .alert(
            Localization.locationPickerPermissionDenied,
            isPresented: $viewModel.isPermissionAlertPresented
        ) {
            Button(Localization.profileMenuSettings) {
                viewModel.didTapOpenSettings()
            }
            Button(Localization.commonCancel, role: .cancel) {}
        }
    }

    // MARK: - Results

    private var resultsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
                ForEach(viewModel.resultRows) { row in
                    resultRow(row)
                }
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            // Fields block → results = 32pt per Figma 143:8636.
            .padding(.top, CGFloat.Spacing.xl)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    /// Figma 143:8656 — 52pt row: mappin badge in a `blueTransparency`
    /// circle, then title (body) over context (caption2).
    private func resultRow(_ row: SearchLocationViewModel.Row) -> some View {
        Button {
            viewModel.didTapResultRow(row)
        } label: {
            HStack(spacing: CGFloat.Spacing.sm) {
                Circle()
                    .fill(Color.App.blueTransparency)
                    .frame(width: 52, height: 52)
                    .overlay {
                        Image(systemName: "mappin")
                            .font(.system(size: 21))
                            .foregroundStyle(Color.App.gray)
                    }

                VStack(alignment: .leading, spacing: 0) {
                    Text(row.title)
                        .font(.App.body)
                        .foregroundStyle(Color.App.text)
                        .lineLimit(1)

                    if let subtitle = row.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.App.caption2)
                            .foregroundStyle(Color.App.gray2)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    SearchLocationView(
        viewModel: SearchLocationViewModel(
            transition: .init(
                didTapBack: {},
                didSelectLocation: { _ in },
                didTapOpenSettings: {}
            ),
            getLocationCompletionsUseCase: PreviewGetLocationCompletionsUseCase(),
            resolveLocationCompletionUseCase: PreviewResolveLocationCompletionUseCase(),
            getUserLocationUseCase: PreviewGetUserLocationUseCase(),
            reverseGeocodeNameUseCase: PreviewReverseGeocodeNameUseCase(),
            observeLocationPermissionUseCase: PreviewObserveLocationPermissionUseCase()
        ),
        autoFocusesSearchField: false
    )
}

private final class PreviewGetLocationCompletionsUseCase: GetLocationCompletionsUseCase {
    func execute(query: String) async -> [SearchLocationCompletion] {
        [
            SearchLocationCompletion(id: 0, title: "Київ", subtitle: "Україна", batchId: UUID()),
            SearchLocationCompletion(id: 1, title: "Київ, вул. Хрещатик", subtitle: "Україна", batchId: UUID())
        ]
    }
}

private final class PreviewResolveLocationCompletionUseCase: ResolveLocationCompletionUseCase {
    func execute(_ completion: SearchLocationCompletion) async -> SearchLocation? {
        SearchLocation(point: GeoPoint(latitude: 50.4501, longitude: 30.5234), name: completion.title)
    }
}

private final class PreviewGetUserLocationUseCase: GetUserLocationUseCase {
    func execute() async -> GeoPoint? { nil }
}

private final class PreviewReverseGeocodeNameUseCase: ReverseGeocodeNameUseCase {
    func execute(_ point: GeoPoint) async -> String? { "Київ" }
}

private final class PreviewObserveLocationPermissionUseCase: ObserveLocationPermissionUseCase {
    func execute() -> AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
    }
}
#endif
