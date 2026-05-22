import SwiftUI

// MARK: - LocationPickerView
//
// Sheet that matches Figma node 1:9257. Presented from EditProfileView via
// `.sheet`. Returns the chosen city through `LocationPickerViewModel.Transition`.

struct LocationPickerView: BaseViewProtocol {

    @StateObject var viewModel: LocationPickerViewModel
    @FocusState private var isSearchFocused: Bool

    var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            navigationBar
            VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
                searchField
                geolocationRow
                suggestionsList
                Spacer(minLength: 0)
            }
            .padding(.horizontal, CGFloat.Spacing.md)
        }
        .background(Color.App.backgroundLight)
        .task {
            // Sheet presentation needs a runloop tick before @FocusState
            // sticks; without the delay the keyboard sometimes doesn't appear.
            try? await Task.sleep(for: .milliseconds(50))
            isSearchFocused = true
        }
    }

    // MARK: - Sheet header
    //
    // Inline header — the picker is a sheet, not part of the UINavigationController
    // stack, so it has no system nav bar to fall back on.

    private var navigationBar: some View {
        ZStack {
            Text(Localization.locationPickerTitle)
                .font(.App.headline)
                .foregroundStyle(Color.App.text)

            HStack {
                Button(Localization.commonCancel, action: viewModel.didTapDismiss)
                    .font(.App.callout)
                    .foregroundStyle(Color.App.brown1)
                Spacer()
            }
        }
        .frame(height: 44)
        .padding(.horizontal, CGFloat.Spacing.md)
    }

    // MARK: - Search field

    private var searchField: some View {
        HStack(spacing: CGFloat.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(Color.App.gray2)

            TextField(
                Localization.locationPickerSearchPlaceholder,
                text: $viewModel.query
            )
            .font(.App.footnote)
            .foregroundStyle(Color.App.text)
            .tint(Color.App.brown1)
            .focused($isSearchFocused)
            .submitLabel(.search)
        }
        .padding(.horizontal, 14)
        .frame(height: 50)
        .overlay {
            Capsule().stroke(Color.App.blueTransparency, lineWidth: 1)
        }
    }

    // MARK: - "Моя геолокація"

    private var geolocationRow: some View {
        Button(action: viewModel.didTapMyGeolocation) {
            HStack(spacing: CGFloat.Spacing.sm) {
                Image(systemName: "location.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.App.brown1)

                Text(Localization.locationPickerMyGeolocation)
                    .font(.App.footnote)
                    .foregroundStyle(Color.App.gray)

                Spacer()

                if viewModel.isLocating {
                    ProgressView().progressViewStyle(.circular)
                }
            }
            .frame(height: 32)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .alert(
            Localization.locationPickerPermissionDenied,
            isPresented: $viewModel.permissionDenied
        ) {
            Button(Localization.okButton, role: .cancel) {}
        }
    }

    // MARK: - Suggestions

    private var suggestionsList: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.suggestions) { suggestion in
                    suggestionRow(suggestion)
                }
            }
        }
    }

    @ViewBuilder
    private func suggestionRow(_ suggestion: LocationPickerViewModel.Suggestion) -> some View {
        Button {
            viewModel.didTapSuggestion(suggestion)
        } label: {
            VStack(alignment: .leading, spacing: CGFloat.Spacing.xxs) {
                Text(suggestion.title)
                    .font(.App.footnote)
                    .foregroundStyle(Color.App.text)
                if !suggestion.subtitle.isEmpty {
                    Text(suggestion.subtitle)
                        .font(.App.caption1)
                        .foregroundStyle(Color.App.gray2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, CGFloat.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        Rectangle()
            .fill(Color.App.blueTransparency)
            .frame(height: 1)
    }
}
