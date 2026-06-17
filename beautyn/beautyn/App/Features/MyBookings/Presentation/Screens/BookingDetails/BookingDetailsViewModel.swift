import Combine
import EventKit
import Foundation
import SwiftUI

// MARK: - BookingDetailsViewModel
//
// Drives the Booking Details screen (Figma 143:3861 future / 143:5143 cancelled /
// 143:5082 past). Built from a full `Booking` (the My Bookings list passes the
// tapped one; the booking flow builds one from the salon + created booking), so
// no fetch is needed for the content. The salon is loaded best-effort only to
// seed the favorite (heart) state, mirroring SalonProfile.

@MainActor
final class BookingDetailsViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        /// Past / cancelled "Забронювати знову" — reopen the salon profile.
        let didTapBookAgain: (_ salonId: String) -> Void
        let didRequireAuth: () -> Void
    }

    // MARK: - State

    enum State {
        case future       // .created
        case past         // .completed
        case cancelled    // .canceled / .deleted
    }

    // MARK: - Presentation models

    struct ShareSheetPresentation: Identifiable {
        let id = UUID()
        let url: URL
        let title: String
    }

    /// Carries the `EKEventStore` + prefilled `EKEvent` to the system event editor.
    struct CalendarDraft: Identifiable {
        let id = UUID()
        let store: EKEventStore
        let event: EKEvent
    }

    struct ServiceRow: Identifiable {
        let id: String
        let name: String
        let description: String?
        let price: String?     // formatted, e.g. "700 грн"; nil when unknown (list bookings)
    }

    // MARK: - Published

    @Published private(set) var isFavorited: Bool = false
    @Published var shareSheet: ShareSheetPresentation?
    @Published var calendarDraft: CalendarDraft?
    @Published var isShowingMapsChooser: Bool = false

    // MARK: - Dependencies

    /// Seeded from the booking handed in at navigation (flash-free first render),
    /// then kept fresh by the shared bookings source of truth so a change made
    /// elsewhere (e.g. a cancel) reflects here.
    @Published private(set) var booking: Booking
    private let transition: Transition
    private let observeBookingUseCase: any ObserveBookingUseCase
    private let getSalonByIdUseCase: any GetSalonByIdUseCase
    private let getSalonShareUseCase: any GetSalonShareUseCase
    private let saveSalonUseCase: any SaveSalonUseCase
    private let unsaveSalonUseCase: any UnsaveSalonUseCase
    private let savedSalonsEventBus: any SavedSalonsEventBus
    private let sessionManager: SessionManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        booking: Booking,
        transition: Transition,
        observeBookingUseCase: any ObserveBookingUseCase,
        getSalonByIdUseCase: any GetSalonByIdUseCase,
        getSalonShareUseCase: any GetSalonShareUseCase,
        saveSalonUseCase: any SaveSalonUseCase,
        unsaveSalonUseCase: any UnsaveSalonUseCase,
        savedSalonsEventBus: any SavedSalonsEventBus,
        sessionManager: SessionManager
    ) {
        self.booking = booking
        self.transition = transition
        self.observeBookingUseCase = observeBookingUseCase
        self.getSalonByIdUseCase = getSalonByIdUseCase
        self.getSalonShareUseCase = getSalonShareUseCase
        self.saveSalonUseCase = saveSalonUseCase
        self.unsaveSalonUseCase = unsaveSalonUseCase
        self.savedSalonsEventBus = savedSalonsEventBus
        self.sessionManager = sessionManager
        super.init()
        observeBooking()
        observeSavedSalonsBus()
    }

    // MARK: - Lifecycle

    override func onViewTask() async {
        await loadFavoriteState()
    }

    // MARK: - Derived state

    var state: State {
        // The CRM often never flips a booking's stored status to "completed" — the
        // backend's My Bookings filter derives past/upcoming from the datetime, not
        // the status (see booking-query.service `buildClientScopeWhere`). Mirror that
        // here: cancelled stays cancelled; otherwise a booking is "past" once its end
        // (or start, when there's no end) time has passed.
        switch booking.status {
        case .canceled, .deleted:
            return .cancelled
        case .completed:
            return .past
        case .created, .unknown:
            let endsAt = booking.endDatetime ?? booking.datetime
            return endsAt < Date() ? .past : .future
        }
    }

    // MARK: - Header display

    var salonName: String { booking.salonName }
    var salonImageURL: URL? { booking.salonImageURL }

    var statusText: String {
        switch state {
        case .future: return Localization.bookingDetailsStatusConfirmed
        case .past: return Localization.bookingDetailsStatusCompleted
        case .cancelled: return Localization.bookingDetailsStatusCancelled
        }
    }

    /// e.g. "Завтра, 25 вер 2025, 9:00 – 10:30" — wraps to two lines per Figma.
    var dateTimeText: String {
        let date = AppointmentDateFormatter.dateString(
            booking.datetime, relativeDay: true, timeZone: booking.timezone
        )
        let time = AppointmentDateFormatter.timeString(
            start: booking.datetime, end: booking.endDatetime, timeZone: booking.timezone
        )
        return time.isEmpty ? date : "\(date), \(time)"
    }

    /// e.g. "90 хв." — empty when the duration is unknown.
    var durationText: String {
        guard let minutes = booking.durationMinutes, minutes > 0 else { return "" }
        return Localization.homeAppointmentDuration("\(minutes)")
    }

    // MARK: - Services / total

    var serviceRows: [ServiceRow] {
        booking.services.map { service in
            ServiceRow(
                id: service.id,
                name: service.name,
                description: service.description,
                price: service.price.map { Localization.priceUAH(Self.formattedPrice($0)) }
            )
        }
    }

    var totalText: String {
        let total = booking.totalPrice ?? booking.services.reduce(0) { $0 + ($1.price ?? 0) }
        return Localization.priceUAH(Self.formattedPrice(total))
    }

    // MARK: - Action availability

    var showsCalendarAction: Bool { state == .future }
    var showsRouteAction: Bool { state == .future && hasRouteDestination }
    var showsMakeChangesAction: Bool { state == .future && booking.bookingUrl != nil }
    var showsBookAgainAction: Bool { state == .past || state == .cancelled }

    var routeSubtitle: String? { booking.salonAddress }

    private var hasRouteDestination: Bool {
        booking.coordinate != nil || !(booking.salonAddress ?? "").isEmpty
    }

    // MARK: - Intents

    func didTapAddToCalendar() {
        let store = EKEventStore()
        Task { [weak self] in
            guard let self else { return }
            do {
                let granted = try await store.requestWriteOnlyAccessToEvents()
                guard granted else {
                    self.showWarning(Localization.bookingDetailsCalendarAccessDenied)
                    return
                }
                let event = EKEvent(eventStore: store)
                event.title = self.calendarEventTitle
                event.startDate = self.booking.datetime
                event.endDate = self.booking.endDatetime
                    ?? self.booking.datetime.addingTimeInterval(3600)
                event.location = self.booking.salonAddress
                if let timezone = self.booking.timezone { event.timeZone = timezone }
                self.calendarDraft = CalendarDraft(store: store, event: event)
            } catch {
                self.showError(error)
            }
        }
    }

    private var calendarEventTitle: String {
        let services = booking.serviceNames.joined(separator: ", ")
        return services.isEmpty ? booking.salonName : "\(booking.salonName) — \(services)"
    }

    func didTapRoute() {
        // Only worth a chooser when there's an actual choice; otherwise go straight
        // to Apple Maps.
        if MapsLauncher.isGoogleMapsInstalled {
            isShowingMapsChooser = true
        } else {
            MapsLauncher.openAppleMaps(routeDestination)
        }
    }

    var isGoogleMapsInstalled: Bool { MapsLauncher.isGoogleMapsInstalled }

    func openAppleMaps() { MapsLauncher.openAppleMaps(routeDestination) }
    func openGoogleMaps() { MapsLauncher.openGoogleMaps(routeDestination) }

    private var routeDestination: MapsLauncher.Destination {
        MapsLauncher.Destination(
            coordinate: booking.coordinate,
            name: booking.salonName,
            address: booking.salonAddress
        )
    }

    func didTapMakeChanges() {
        guard let url = booking.bookingUrl else { return }
        openWebView(url: url, title: booking.salonName)
    }

    func didTapBookAgain() {
        transition.didTapBookAgain(booking.salonId)
    }

    func didTapShare() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let share = try await self.getSalonShareUseCase.execute(id: self.booking.salonId)
                self.shareSheet = ShareSheetPresentation(url: share.url, title: share.title)
            } catch {
                self.showError(error)
            }
        }
    }

    func didTapFavorite() {
        guard requireAuth() else { return }
        let wasFavorited = isFavorited
        isFavorited = !wasFavorited
        Task { [weak self] in
            guard let self else { return }
            do {
                if wasFavorited {
                    try await self.unsaveSalonUseCase.execute(salonId: self.booking.salonId)
                } else {
                    try await self.saveSalonUseCase.execute(salonId: self.booking.salonId)
                }
            } catch {
                self.isFavorited = wasFavorited
                self.showError(error)
            }
        }
    }

    // MARK: - Private

    private func requireAuth() -> Bool {
        guard sessionManager.isAuthenticated else {
            transition.didRequireAuth()
            return false
        }
        return true
    }

    private func loadFavoriteState() async {
        // Best-effort: the booking already carries all display data, so a failure
        // just leaves the heart in its default (unsaved) state.
        guard let salon = try? await getSalonByIdUseCase.execute(id: booking.salonId) else { return }
        isFavorited = salon.isSaved
    }

    private func observeBooking() {
        // Keep the screen in sync with the source of truth. Ignore `nil` (e.g. the
        // booking isn't cached on a cold entry) so we keep showing the seed.
        observeBookingUseCase.execute(id: booking.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updated in
                guard let self, let updated else { return }
                self.booking = updated
            }
            .store(in: &cancellables)
    }

    private func observeSavedSalonsBus() {
        savedSalonsEventBus.changes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] change in
                guard let self, change.salonId == self.booking.salonId else { return }
                self.isFavorited = change.isSaved
            }
            .store(in: &cancellables)
    }

    private static func formattedPrice(_ price: Double) -> String {
        price.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", price)
            : String(format: "%.2f", price)
    }
}
