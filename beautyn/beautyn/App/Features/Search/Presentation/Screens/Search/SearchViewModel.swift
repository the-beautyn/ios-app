import Foundation
import Combine
import SwiftUI

// MARK: - SearchViewModel
//
// Drives the text-search sheet (Figma 143:8526): search history for an
// authenticated user (empty field) and live salon suggestions while typing.
// The keyboard "Search" key hands the query + picked location back to the
// map screen via `Transition.didSubmit`.

@MainActor
final class SearchViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        let didTapClose: () -> Void
        let didTapLocationField: (_ onSelect: @escaping (SearchLocation) -> Void) -> Void
        /// Carries the sheet's current state too — opening a salon applies the
        /// search to the map behind, so backing out of the salon profile lands
        /// on the results the user just searched for.
        let didSelectSalon: (_ salonId: String, _ submission: SearchSubmission) -> Void
        let didSubmit: (SearchSubmission) -> Void
    }

    // MARK: - Row (Presentation Entity)

    /// One list row — history and salon results share the same shape.
    /// `id` is the history row id for history rows, the salon id for results.
    struct Row: Identifiable, Equatable {
        let id: String
        let title: String
        let subtitle: String?
        let imageUrl: String?
    }

    // MARK: - Constants

    private static let historyLimit = 7
    private static let resultsLimit = 10
    private static let suggestionsDebounce: Duration = .milliseconds(300)

    // MARK: - Published

    @Published var query: String = "" {
        didSet { queryChanged(from: oldValue) }
    }
    @Published private(set) var historyRows: [Row] = []
    @Published private(set) var resultRows: [Row] = []
    @Published private(set) var selectedLocation: SearchLocation?

    // MARK: - View state

    var showsHistorySection: Bool { trimmedQuery.isEmpty && !historyRows.isEmpty }
    var showsResultsSection: Bool { !trimmedQuery.isEmpty && !resultRows.isEmpty }
    var locationTitle: String { selectedLocation?.name ?? Localization.locationPickerTitle }

    // MARK: - Dependencies

    private let transition: Transition
    private let getSearchHistoryUseCase: any GetSearchHistoryUseCase
    private let clearSearchHistoryUseCase: any ClearSearchHistoryUseCase
    private let deleteSearchHistoryItemUseCase: any DeleteSearchHistoryItemUseCase
    private let searchSalonsUseCase: any SearchSalonsUseCase
    private let sessionManager: SessionManager

    /// What the map was looking at when the sheet opened — the distance-
    /// ranking center until the user picks a location explicitly.
    private let mapCenter: GeoPoint?

    // Domain backing for the published rows — intents resolve row ids
    // against these.
    private var historyItems: [SearchHistoryItem] = []
    private var salons: [SearchSalon] = []

    private var suggestionsTask: Task<Void, Never>?
    private var hasStartedInitialLoad = false

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// The picked location wins; the map's center is the fallback.
    private var searchCenter: GeoPoint? {
        selectedLocation?.point ?? mapCenter
    }

    // MARK: - Init

    init(
        transition: Transition,
        initialQuery: String?,
        initialLocation: SearchLocation?,
        mapCenter: GeoPoint?,
        getSearchHistoryUseCase: any GetSearchHistoryUseCase,
        clearSearchHistoryUseCase: any ClearSearchHistoryUseCase,
        deleteSearchHistoryItemUseCase: any DeleteSearchHistoryItemUseCase,
        searchSalonsUseCase: any SearchSalonsUseCase,
        sessionManager: SessionManager
    ) {
        self.transition = transition
        self.mapCenter = mapCenter
        self.getSearchHistoryUseCase = getSearchHistoryUseCase
        self.clearSearchHistoryUseCase = clearSearchHistoryUseCase
        self.deleteSearchHistoryItemUseCase = deleteSearchHistoryItemUseCase
        self.searchSalonsUseCase = searchSalonsUseCase
        self.sessionManager = sessionManager
        super.init()
        // Assigning after super.init keeps `didSet` (and the debounce) inert
        // for the prefill — `onViewTask` fetches its results undebounced.
        self.query = initialQuery ?? ""
        self.selectedLocation = initialLocation
    }

    // MARK: - Lifecycle

    override func onViewTask() async {
        guard !hasStartedInitialLoad else { return }
        hasStartedInitialLoad = true

        // Reopened prefilled (an applied query is being edited) — restore
        // the matching results right away.
        if !trimmedQuery.isEmpty {
            fetchResults(for: trimmedQuery, debounced: false)
        }
        await loadHistory()
    }

    // MARK: - Intents

    func didTapClose() {
        transition.didTapClose()
    }

    func didTapLocationField() {
        transition.didTapLocationField { [weak self] location in
            guard let self else { return }
            self.selectedLocation = location
            // Re-rank what's on screen around the newly picked place.
            if !self.trimmedQuery.isEmpty {
                self.fetchResults(for: self.trimmedQuery, debounced: false)
            }
        }
    }

    func didTapDateField() {
        // Placeholder — date filtering comes with a later design iteration.
    }

    func didSubmit() {
        transition.didSubmit(currentSubmission())
    }

    func didTapHistoryRow(_ row: Row) {
        guard let item = historyItems.first(where: { $0.id == row.id }) else { return }
        transition.didSelectSalon(item.salonId, currentSubmission(focusing: item.point))
    }

    func didTapResultRow(_ row: Row) {
        guard let salon = salons.first(where: { $0.id == row.id }) else { return }
        let point = salon.latitude.flatMap { latitude in
            salon.longitude.map { GeoPoint(latitude: latitude, longitude: $0) }
        }
        transition.didSelectSalon(salon.id, currentSubmission(focusing: point))
    }

    func didTapClearHistory() {
        let backup = historyItems
        guard !backup.isEmpty else { return }
        setHistory([])

        Task { [weak self] in
            do {
                try await self?.clearSearchHistoryUseCase.execute()
            } catch {
                guard let self else { return }
                self.setHistory(backup)
                self.showError(error)
            }
        }
    }

    func deleteHistoryRow(_ row: Row) {
        guard let index = historyItems.firstIndex(where: { $0.id == row.id }) else { return }
        let item = historyItems[index]
        var updated = historyItems
        updated.remove(at: index)
        setHistory(updated)

        Task { [weak self] in
            do {
                try await self?.deleteSearchHistoryItemUseCase.execute(id: item.id)
            } catch {
                guard let self else { return }
                var restored = self.historyItems
                restored.insert(item, at: min(index, restored.count))
                self.setHistory(restored)
                self.showError(error)
            }
        }
    }

    // MARK: - Private

    private func currentSubmission(focusing point: GeoPoint? = nil) -> SearchSubmission {
        let trimmed = trimmedQuery
        return SearchSubmission(
            query: trimmed.isEmpty ? nil : trimmed,
            location: selectedLocation,
            focusPoint: point
        )
    }

    private func loadHistory() async {
        // History is per-user — the section simply doesn't exist for
        // anonymous visitors.
        guard sessionManager.isAuthenticated else { return }
        do {
            let items = try await getSearchHistoryUseCase.execute(limit: Self.historyLimit)
            setHistory(items)
        } catch {
            // Auxiliary content — opening the sheet shouldn't alert on a
            // failed history fetch; the section just stays hidden.
        }
    }

    private func setHistory(_ items: [SearchHistoryItem]) {
        historyItems = items
        withAnimation { historyRows = items.map(Self.makeRow) }
    }

    private func setSalons(_ items: [SearchSalon]) {
        salons = items
        withAnimation { resultRows = items.map(Self.makeRow) }
    }

    private func queryChanged(from oldValue: String) {
        guard oldValue != query else { return }
        suggestionsTask?.cancel()

        let trimmed = trimmedQuery
        guard !trimmed.isEmpty else {
            setSalons([])
            return
        }
        fetchResults(for: trimmed, debounced: true)
    }

    /// Same pipeline as the map (`POST /search`) — the query text plus the
    /// distance-ranking center. A text query bypasses the server's radius
    /// cut, so far-away name matches still appear, just lower in the list.
    private func fetchResults(for text: String, debounced: Bool) {
        suggestionsTask?.cancel()
        suggestionsTask = Task { [weak self] in
            if debounced {
                guard (try? await Task.sleep(for: Self.suggestionsDebounce)) != nil else { return }
            }
            guard let self, !Task.isCancelled else { return }
            do {
                let searchResults = try await self.searchSalonsUseCase.execute(SearchQuery(
                    query: text,
                    centerLat: self.searchCenter?.latitude,
                    centerLng: self.searchCenter?.longitude,
                    // Only meaningful when the user explicitly picked a place;
                    // the map-center fallback has no known kind.
                    locationType: self.selectedLocation?.kind,
                    page: 1,
                    limit: Self.resultsLimit
                ))
                // Drop stale responses — only the freshest query owns the list.
                guard !Task.isCancelled, self.trimmedQuery == text else { return }
                self.setSalons(searchResults.items)
            } catch is CancellationError {
            } catch {
                // Keep the previous list — a failed lookup mid-typing
                // shouldn't alert on every keystroke.
            }
        }
    }

    // MARK: - Mapping

    private static func makeRow(_ item: SearchHistoryItem) -> Row {
        Row(id: item.id, title: item.name, subtitle: nil, imageUrl: item.imageUrl)
    }

    private static func makeRow(_ salon: SearchSalon) -> Row {
        Row(id: salon.id, title: salon.name, subtitle: salon.address, imageUrl: salon.imageUrl)
    }
}
