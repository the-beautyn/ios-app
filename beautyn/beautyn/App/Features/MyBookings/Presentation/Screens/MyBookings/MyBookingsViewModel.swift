import Foundation
import Combine

// MARK: - MyBookingsViewModel

@MainActor
final class MyBookingsViewModel: BaseViewModel {

    struct Transition {
        let didTapBookingDetails: (String) -> Void   // bookingId
        let didTapBook: (String) -> Void             // salonId
    }

    enum TabState {
        case idle
        case loading
        case loaded([Booking])
        case failed
    }

    @Published private(set) var selectedTab: BookingTab = .upcoming
    @Published private(set) var states: [BookingTab: TabState] = [:]

    private let transition: Transition
    private let getMyBookingsUseCase: any GetMyBookingsUseCase
    private let bookingEventBus: any BookingEventBus
    private var cancellables = Set<AnyCancellable>()

    init(
        transition: Transition,
        getMyBookingsUseCase: any GetMyBookingsUseCase,
        bookingEventBus: any BookingEventBus
    ) {
        self.transition = transition
        self.getMyBookingsUseCase = getMyBookingsUseCase
        self.bookingEventBus = bookingEventBus
        super.init()
        observeBookingCreated()
    }

    var currentState: TabState {
        states[selectedTab] ?? .idle
    }

    override func onViewTask() async {
        await loadIfNeeded(selectedTab)
    }

    func selectTab(_ tab: BookingTab) {
        guard tab != selectedTab else { return }
        selectedTab = tab
        Task { await loadIfNeeded(tab) }
    }

    func refresh() async {
        // Pull-to-refresh: keep the current rows on screen (the system spinner
        // already signals progress) so the list doesn't blank out and flash.
        await load(selectedTab, keepCurrent: true)
    }

    // MARK: - Card actions

    func didTapDetails(_ booking: Booking) {
        transition.didTapBookingDetails(booking.id)
    }

    func didTapBook(_ booking: Booking) {
        transition.didTapBook(booking.salonId)
    }

    // MARK: - Booking events

    private func observeBookingCreated() {
        bookingEventBus.bookingCreated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleBookingCreated()
            }
            .store(in: &cancellables)
    }

    private func handleBookingCreated() {
        // A new booking is always "upcoming". Drop the other tabs' caches so they
        // refetch lazily when next shown, and silently refresh the visible tab in
        // place (keep current rows to avoid a blank flash).
        let visible = selectedTab
        states = states.filter { $0.key == visible }
        Task { await load(visible, keepCurrent: true) }
    }

    // MARK: - Loading

    private func loadIfNeeded(_ tab: BookingTab) async {
        switch states[tab] {
        case .loaded, .loading:
            return
        default:
            await load(tab)
        }
    }

    private func load(_ tab: BookingTab, keepCurrent: Bool = false) async {
        if !keepCurrent {
            states[tab] = .loading
        }
        do {
            let bookings = try await getMyBookingsUseCase.execute(tab: tab)
            states[tab] = .loaded(bookings)
        } catch {
            if !keepCurrent {
                states[tab] = .failed
            }
            showError(error, scope: .current)
        }
    }
}
