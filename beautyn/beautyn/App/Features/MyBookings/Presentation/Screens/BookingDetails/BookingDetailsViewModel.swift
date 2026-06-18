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
        /// Open details for a different booking, replacing the current screen —
        /// used after an EasyWeek reschedule / new booking made via "Внести зміни".
        let didOpenBookingDetails: (_ booking: Booking) -> Void
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
    private let refreshBookingUseCase: any RefreshBookingUseCase
    private let syncBookingFromCrmUseCase: any SyncBookingFromCrmUseCase
    private let confirmEasyweekBookingUseCase: any ConfirmEasyweekBookingUseCase
    private let getCurrentUserUseCase: any GetCurrentUserUseCase
    private let getSalonByIdUseCase: any GetSalonByIdUseCase
    private let getSalonShareUseCase: any GetSalonShareUseCase
    private let saveSalonUseCase: any SaveSalonUseCase
    private let unsaveSalonUseCase: any UnsaveSalonUseCase
    private let savedSalonsEventBus: any SavedSalonsEventBus
    private let sessionManager: SessionManager
    private var cancellables = Set<AnyCancellable>()
    /// The single-booking observation, kept separately so a reschedule can re-point
    /// it from the old booking to the new one.
    private var bookingObservation: AnyCancellable?

    /// Set when an EasyWeek "Внести зміни" session ends in a completed booking, so
    /// the sheet-dismiss handler doesn't also treat it as a plain edit/cancel.
    private var makeChangeDidComplete = false

    // MARK: - Init

    init(
        booking: Booking,
        transition: Transition,
        observeBookingUseCase: any ObserveBookingUseCase,
        refreshBookingUseCase: any RefreshBookingUseCase,
        syncBookingFromCrmUseCase: any SyncBookingFromCrmUseCase,
        confirmEasyweekBookingUseCase: any ConfirmEasyweekBookingUseCase,
        getCurrentUserUseCase: any GetCurrentUserUseCase,
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
        self.refreshBookingUseCase = refreshBookingUseCase
        self.syncBookingFromCrmUseCase = syncBookingFromCrmUseCase
        self.confirmEasyweekBookingUseCase = confirmEasyweekBookingUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.getSalonByIdUseCase = getSalonByIdUseCase
        self.getSalonShareUseCase = getSalonShareUseCase
        self.saveSalonUseCase = saveSalonUseCase
        self.unsaveSalonUseCase = unsaveSalonUseCase
        self.savedSalonsEventBus = savedSalonsEventBus
        self.sessionManager = sessionManager
        super.init()
        observeBooking(id: booking.id)
        observeSavedSalonsBus()
    }

    // MARK: - Lifecycle

    override func onViewTask() async {
        // Best-effort refresh so the screen is fresh and carries the CRM type
        // (the Home-feed entry seeds `.unknown`) before "Внести зміни" is tapped.
        _ = try? await refreshBookingUseCase.execute(id: booking.id)
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
        makeChangeDidComplete = false

        switch booking.crmType {
        case .easyweek:
            // EasyWeek reschedule / new booking creates a NEW appointment and lands
            // on the widget's completion page — drive the id-capturing webview so we
            // catch its UUID. A plain close (cancel) just re-syncs the existing one.
            Task { [weak self] in
                guard let self else { return }
                let autofill = await self.makeAutofill()
                self.openWebBooking(
                    url: url,
                    title: self.booking.salonName,
                    configuration: .easyWeek,
                    autofill: autofill,
                    // Exclude the booking being changed so the scraper captures the
                    // NEW appointment, not the old one still referenced on the page.
                    excludeBookingId: self.booking.crmRecordId,
                    onCompleted: { [weak self] result in
                        self?.handleEasyweekMakeChangeCompleted(result)
                    },
                    onDismiss: { [weak self] in
                        self?.refreshBookingFromCrmAfterMakeChange()
                    }
                )
            }

        case .altegio, .unknown:
            // Altegio edits the same appointment in place — just re-pull it on close.
            openWebView(url: url, title: booking.salonName) { [weak self] in
                self?.refreshBookingFromCrmAfterMakeChange()
            }
        }
    }

    /// Re-pull the current booking from its CRM after the "Внести зміни" sheet
    /// closes without a new booking (Altegio edit/cancel, or EasyWeek cancel).
    private func refreshBookingFromCrmAfterMakeChange() {
        guard !makeChangeDidComplete else { return }
        let id = booking.id
        Task { [weak self] in
            // Best-effort: the cache (and every screen observing it) updates on success.
            try? await self?.syncBookingFromCrmUseCase.execute(id: id)
        }
    }

    /// EasyWeek widget reported a completed booking. EasyWeek has no native
    /// reschedule — a completion always means a NEW booking was created, and the
    /// original may or may not have been cancelled in the same session. We can't
    /// tell a reschedule from a cancel-then-rebook (identical state, no link), so we
    /// treat every case the same: confirm the new booking, re-sync the original so
    /// it reflects its real CRM state (cancelled or still active), then open the new
    /// booking. The original stays in the system (e.g. in the Cancelled tab).
    private func handleEasyweekMakeChangeCompleted(_ result: WebBookingResult) {
        makeChangeDidComplete = true
        webBookingPresentation = nil
        let salonId = booking.salonId
        let originalBookingId = booking.id
        Task { [weak self] in
            guard let self else { return }
            self.showLoader()
            defer { self.hideLoader() }
            do {
                let newBooking = try await self.confirmEasyweekBookingUseCase.execute(
                    salonId: salonId,
                    bookingUuid: result.bookingId
                )
                // Re-pull the original so it shows its current state (it may have been
                // cancelled in the same webview session).
                _ = try? await self.syncBookingFromCrmUseCase.execute(id: originalBookingId)
                self.transition.didOpenBookingDetails(newBooking)
            } catch {
                self.showError(error)
            }
        }
    }

    private func makeAutofill() async -> WebBookingAutofill {
        let profile = try? await getCurrentUserUseCase.execute()
        return WebBookingAutofill(
            firstName: profile?.name ?? "",
            lastName: profile?.secondName ?? "",
            email: profile?.email ?? "",
            phone: profile?.phone ?? ""
        )
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

    private func observeBooking(id: String) {
        // Keep the screen in sync with the source of truth. Ignore `nil` (e.g. the
        // booking isn't cached on a cold entry, or after a reschedule drops the old
        // one) so we keep showing the current booking. Re-assigning cancels any
        // previous subscription, letting a reschedule re-point to the new id.
        bookingObservation = observeBookingUseCase.execute(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updated in
                guard let self, let updated else { return }
                self.booking = updated
            }
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
