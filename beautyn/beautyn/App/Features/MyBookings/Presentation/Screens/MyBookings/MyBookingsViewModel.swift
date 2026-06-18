import Foundation
import Combine

// MARK: - MyBookingsViewModel
//
// Reads from the shared bookings source of truth (via `ObserveBookingsUseCase`)
// and splits the cached array into the three tabs locally using `BookingCategory`
// — the same bucketing the backend filters on, so a booking can't land in two
// tabs or none. Selecting a tab / pulling to refresh triggers a category fetch
// (`RefreshBookingsUseCase`) which merges into the cache; the observer then
// re-emits and the tabs re-derive. The VM never touches the repository directly.

@MainActor
final class MyBookingsViewModel: BaseViewModel {

    struct Transition {
        let didTapBookingDetails: (Booking) -> Void   // the tapped booking
        let didTapBook: (String) -> Void              // salonId
    }

    enum TabState {
        case idle
        case loading
        case loaded([Booking])
        case failed
    }

    // The network fetch status per tab (separate from the cached data, which
    // arrives via the observer).
    private enum FetchPhase {
        case idle
        case loading
        case loaded
        case failed
    }

    @Published private(set) var selectedTab: BookingTab = .upcoming
    @Published private var allBookings: [Booking] = []
    @Published private var fetchPhase: [BookingTab: FetchPhase] = [:]

    private let transition: Transition
    private let observeBookingsUseCase: any ObserveBookingsUseCase
    private let refreshBookingsUseCase: any RefreshBookingsUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        transition: Transition,
        observeBookingsUseCase: any ObserveBookingsUseCase,
        refreshBookingsUseCase: any RefreshBookingsUseCase
    ) {
        self.transition = transition
        self.observeBookingsUseCase = observeBookingsUseCase
        self.refreshBookingsUseCase = refreshBookingsUseCase
        super.init()
        observeBookings()
    }

    var currentState: TabState {
        state(for: selectedTab)
    }

    func state(for tab: BookingTab) -> TabState {
        let bookings = self.bookings(for: tab)
        switch fetchPhase[tab] ?? .idle {
        case .idle:
            return bookings.isEmpty ? .idle : .loaded(bookings)
        case .loading:
            return bookings.isEmpty ? .loading : .loaded(bookings)
        case .loaded:
            return .loaded(bookings)
        case .failed:
            return bookings.isEmpty ? .failed : .loaded(bookings)
        }
    }

    override func onViewTask() async {
        await openTab(selectedTab)
    }

    func selectTab(_ tab: BookingTab) {
        guard tab != selectedTab else { return }
        selectedTab = tab
        Task { await openTab(tab) }
    }

    func refresh() async {
        // Pull-to-refresh: keep the rows on screen (cache already feeds them) and
        // rely on the system spinner instead of the loading state.
        await load(selectedTab)
    }

    // MARK: - Card actions

    func didTapDetails(_ booking: Booking) {
        transition.didTapBookingDetails(booking)
    }

    func didTapBook(_ booking: Booking) {
        transition.didTapBook(booking.salonId)
    }

    // MARK: - Cache

    private func observeBookings() {
        observeBookingsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bookings in
                self?.allBookings = bookings
            }
            .store(in: &cancellables)
    }

    private func bookings(for tab: BookingTab) -> [Booking] {
        let now = Date()
        let filtered = allBookings.filter { tab.category.contains($0, now: now) }
        return tab.category.sorted(filtered)
    }

    // MARK: - Loading

    // Opening a tab: if it's never been fetched, fetch it (showing the loading
    // state only when there's nothing cached to display); otherwise refresh
    // silently in the background.
    private func openTab(_ tab: BookingTab) async {
        switch fetchPhase[tab] ?? .idle {
        case .loading, .loaded:
            await load(tab, silent: true)
        case .idle, .failed:
            await load(tab)
        }
    }

    private func load(_ tab: BookingTab, silent: Bool = false) async {
        if !silent, bookings(for: tab).isEmpty {
            fetchPhase[tab] = .loading
        }
        do {
            try await refreshBookingsUseCase.execute(category: tab.category)
            fetchPhase[tab] = .loaded
        } catch {
            if fetchPhase[tab] != .loaded, bookings(for: tab).isEmpty {
                fetchPhase[tab] = .failed
            }
            if !silent {
                showError(error, scope: .current)
            }
        }
    }
}
