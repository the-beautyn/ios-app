import Foundation
import Combine
import SwiftUI

// MARK: - SearchLocationViewModel
//
// Drives the "Локація" page (Figma 143:8586) pushed inside the search sheet:
// a debounced place lookup (addresses / cities / POIs, each with a
// coordinate) plus the "Моя геолокація" shortcut. The picked place returns
// to the search screen via `Transition.didSelectLocation`.

@MainActor
final class SearchLocationViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        let didTapBack: () -> Void
        let didSelectLocation: (SearchLocation) -> Void
        let didTapOpenSettings: () -> Void
    }

    // MARK: - Row (Presentation Entity)

    /// One autocomplete row — display strings only; the tapped row is
    /// resolved back to its completion by id.
    struct Row: Identifiable, Equatable {
        let id: Int
        let title: String
        let subtitle: String?
    }

    // MARK: - Constants

    private static let searchDebounce: Duration = .milliseconds(300)

    // MARK: - Published

    @Published var query: String = "" {
        didSet { queryChanged(from: oldValue) }
    }
    @Published private(set) var resultRows: [Row] = []
    @Published private(set) var isLocating = false
    @Published var isPermissionAlertPresented = false

    // MARK: - Dependencies

    private let transition: Transition
    private let getLocationCompletionsUseCase: any GetLocationCompletionsUseCase
    private let resolveLocationCompletionUseCase: any ResolveLocationCompletionUseCase
    private let getUserLocationUseCase: any GetUserLocationUseCase
    private let reverseGeocodeNameUseCase: any ReverseGeocodeNameUseCase

    /// Domain backing for the published rows — taps resolve row ids
    /// against these.
    private var completions: [SearchLocationCompletion] = []

    private var searchTask: Task<Void, Never>?
    private var isResolving = false
    private var isPermissionDenied = false
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        transition: Transition,
        getLocationCompletionsUseCase: any GetLocationCompletionsUseCase,
        resolveLocationCompletionUseCase: any ResolveLocationCompletionUseCase,
        getUserLocationUseCase: any GetUserLocationUseCase,
        reverseGeocodeNameUseCase: any ReverseGeocodeNameUseCase,
        observeLocationPermissionUseCase: any ObserveLocationPermissionUseCase
    ) {
        self.transition = transition
        self.getLocationCompletionsUseCase = getLocationCompletionsUseCase
        self.resolveLocationCompletionUseCase = resolveLocationCompletionUseCase
        self.getUserLocationUseCase = getUserLocationUseCase
        self.reverseGeocodeNameUseCase = reverseGeocodeNameUseCase
        super.init()

        observeLocationPermissionUseCase.execute()
            .sink { [weak self] isDenied in
                self?.isPermissionDenied = isDenied
            }
            .store(in: &cancellables)
    }

    // MARK: - Intents

    func didTapBack() {
        transition.didTapBack()
    }

    func didTapResultRow(_ row: Row) {
        guard !isResolving,
              let completion = completions.first(where: { $0.id == row.id }) else { return }
        isResolving = true

        Task { [weak self] in
            guard let self else { return }
            defer { self.isResolving = false }
            self.showLoader()
            let location = await self.resolveLocationCompletionUseCase.execute(completion)
            self.hideLoader()
            guard let location else { return }
            self.transition.didSelectLocation(location)
        }
    }

    func didTapMyLocation() {
        guard !isLocating else { return }
        guard !isPermissionDenied else {
            isPermissionAlertPresented = true
            return
        }

        Task { [weak self] in
            guard let self else { return }
            self.isLocating = true
            defer { self.isLocating = false }

            // Prompts for when-in-use permission when undetermined.
            guard let point = await self.getUserLocationUseCase.execute() else {
                if self.isPermissionDenied {
                    self.isPermissionAlertPresented = true
                }
                return
            }
            let name = await self.reverseGeocodeNameUseCase.execute(point)
            self.transition.didSelectLocation(SearchLocation(
                point: point,
                name: name ?? Localization.locationPickerMyGeolocation
            ))
        }
    }

    func didTapOpenSettings() {
        transition.didTapOpenSettings()
    }

    // MARK: - Private

    private func queryChanged(from oldValue: String) {
        guard oldValue != query else { return }
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            setCompletions([])
            return
        }

        searchTask = Task { [weak self] in
            guard (try? await Task.sleep(for: Self.searchDebounce)) != nil else { return }
            guard let self, !Task.isCancelled else { return }

            let found = await self.getLocationCompletionsUseCase.execute(query: trimmed)
            // Drop stale responses — only the freshest query owns the list.
            let current = self.query.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !Task.isCancelled, current == trimmed else { return }
            self.setCompletions(found)
        }
    }

    private func setCompletions(_ items: [SearchLocationCompletion]) {
        completions = items
        withAnimation {
            resultRows = items.map { Row(id: $0.id, title: $0.title, subtitle: $0.subtitle) }
        }
    }
}
