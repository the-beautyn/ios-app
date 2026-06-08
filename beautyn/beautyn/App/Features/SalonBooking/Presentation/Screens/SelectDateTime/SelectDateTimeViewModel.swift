import Combine
import Foundation
import SwiftUI

// MARK: - SelectDateTimeViewModel

@MainActor
final class SelectDateTimeViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        /// Move to the confirmation step with the chosen services, specialist and
        /// the picked slot's datetime (ISO 8601).
        let didContinue: (_ salon: Salon,
                          _ serviceIds: Set<String>,
                          _ workerId: String?,
                          _ datetime: String) -> Void
    }

    // MARK: - Published State

    /// Bookable masters for the selected services, leading with "Будь-який"
    /// (rendered by `MasterPickerView`, so this excludes the "Any" option).
    @Published private(set) var masters: [MasterModel] = []
    /// `nil` = "Будь-який" (any master).
    @Published private(set) var selectedMasterId: String?

    /// Bookable days in the displayed month (drives the calendar's availability).
    @Published private(set) var availableDates: Set<Date> = []
    /// Month the calendar opens on — only read once, when the calendar is built.
    @Published private(set) var initialMonth: Date?
    @Published var selectedDate: Date?

    /// Slots for `selectedDate`, and the chosen one's datetime (ISO 8601).
    @Published private(set) var timeSlots: [AltegioBookingSlot] = []
    @Published private(set) var selectedSlotDatetime: String?

    @Published private(set) var isLoadingDates: Bool = false
    @Published private(set) var isLoadingSlots: Bool = false

    @Published var isEditingServices: Bool = false

    // MARK: - Dependencies

    private let salon: Salon
    @Published private(set) var selectedServiceIds: Set<String>
    private let transition: Transition
    private let getAltegioAvailableWorkersUseCase: any GetAltegioAvailableWorkersUseCase
    private let getAltegioBookingDatesUseCase: any GetAltegioBookingDatesUseCase
    private let getAltegioTimeSlotsUseCase: any GetAltegioTimeSlotsUseCase

    /// Worker / slot carried from the salon profile, used only to preselect.
    private let preselectedWorkerId: String?
    private let preselectedDatetime: String?

    /// Month currently shown by the calendar (tracked so date loads target it).
    private var displayMonth: Date
    /// Service basket snapshot taken when the edit sheet opens, to detect changes.
    private var serviceIdsBeforeEdit: Set<String> = []

    private var datesTask: Task<Void, Never>?
    private var slotsTask: Task<Void, Never>?

    // MARK: - Init

    init(
        salon: Salon,
        selectedServiceIds: Set<String>,
        workerId: String?,
        datetime: String?,
        transition: Transition,
        getAltegioAvailableWorkersUseCase: any GetAltegioAvailableWorkersUseCase,
        getAltegioBookingDatesUseCase: any GetAltegioBookingDatesUseCase,
        getAltegioTimeSlotsUseCase: any GetAltegioTimeSlotsUseCase
    ) {
        self.salon = salon
        self.selectedServiceIds = selectedServiceIds
        self.transition = transition
        self.preselectedWorkerId = workerId
        self.preselectedDatetime = datetime
        self.selectedMasterId = workerId
        self.getAltegioAvailableWorkersUseCase = getAltegioAvailableWorkersUseCase
        self.getAltegioBookingDatesUseCase = getAltegioBookingDatesUseCase
        self.getAltegioTimeSlotsUseCase = getAltegioTimeSlotsUseCase

        // Preselect from a carried slot datetime (chosen on the salon profile),
        // opening the calendar on its month. We key off the date portion of the
        // string (same `yyyy-MM-dd` the dates API uses) so the selected day
        // matches the calendar grid regardless of the datetime's timezone.
        let preselectedDate = datetime.flatMap(Self.dayDate(from:))
        self.selectedDate = preselectedDate
        self.displayMonth = preselectedDate ?? Date()
        self.initialMonth = preselectedDate
        super.init()
    }

    // MARK: - Lifecycle

    override func onViewTask() async {
        showLoader()
        await loadMasters()
        await loadDates(for: displayMonth)
        // If we arrived with a date preselected, load its slots and re-highlight
        // the carried slot.
        if let selectedDate {
            await loadSlots(for: selectedDate, preselect: preselectedDatetime)
        }
        hideLoader()
    }

    // MARK: - Masters

    private func loadMasters() async {
        do {
            let workers = try await getAltegioAvailableWorkersUseCase.execute(
                salonId: salon.id,
                serviceIds: Array(selectedServiceIds),
                datetime: nil,
                includeSlots: false
            )
            let bookableIds = Set(workers.filter { $0.isBookable }.map { $0.id })
            // We already hold the rich `SalonWorker` on device — join by id for
            // the name + photo. Preserve the salon's worker order.
            masters = salon.workers
                .filter { bookableIds.contains($0.id) }
                .map { worker in
                    MasterModel(
                        id: worker.id,
                        name: worker.firstName.isEmpty ? worker.lastName : worker.firstName,
                        imageURL: worker.photoUrl.flatMap(URL.init(string:))
                    )
                }
            // A preselected master that can't do the current services falls back
            // to "Будь-який".
            if let selectedMasterId, !bookableIds.contains(selectedMasterId) {
                self.selectedMasterId = nil
            }
        } catch {
            showError(error)
        }
    }

    // MARK: - Dates

    private func loadDates(for month: Date) async {
        datesTask?.cancel()
        guard let range = Self.monthRange(for: month) else { return }
        isLoadingDates = true
        let task = Task { [weak self] in
            guard let self else { return }
            do {
                let dates = try await self.getAltegioBookingDatesUseCase.execute(
                    salonId: self.salon.id,
                    serviceIds: Array(self.selectedServiceIds),
                    workerId: self.selectedMasterId,
                    dateFrom: range.from,
                    dateTo: range.to
                )
                try Task.checkCancellation()
                self.availableDates = Set(dates)
                self.isLoadingDates = false
            } catch is CancellationError {
                // Superseded by a newer load.
            } catch {
                self.isLoadingDates = false
                self.showError(error)
            }
        }
        datesTask = task
        await task.value
    }

    // MARK: - Slots

    private func loadSlots(for date: Date, preselect datetime: String? = nil) async {
        slotsTask?.cancel()
        isLoadingSlots = true
        let dateString = Self.apiDateFormatter.string(from: date)
        let task = Task { [weak self] in
            guard let self else { return }
            do {
                let slots = try await self.getAltegioTimeSlotsUseCase.execute(
                    salonId: self.salon.id,
                    date: dateString,
                    workerId: self.selectedMasterId,
                    serviceIds: Array(self.selectedServiceIds)
                )
                try Task.checkCancellation()
                self.timeSlots = slots
                self.selectedSlotDatetime = Self.resolvePreselectedSlot(datetime, in: slots)
                self.isLoadingSlots = false
            } catch is CancellationError {
                // Superseded by a newer load.
            } catch {
                self.isLoadingSlots = false
                self.showError(error)
            }
        }
        slotsTask = task
        await task.value
    }

    // MARK: - Intents

    // `MasterPickerView` writes the tapped id here; the setter routes it through
    // `didSelectMaster` so availability reloads. A fresh binding per render,
    // mirroring SelectService's per-tab search bindings.
    var masterSelection: Binding<String?> {
        Binding(get: { self.selectedMasterId }, set: { self.didSelectMaster($0) })
    }

    func didSelectMaster(_ id: String?) {
        guard id != selectedMasterId else { return }
        selectedMasterId = id
        // Availability is per-master: reset the day/time picks and reload the
        // current month's days for the new master.
        selectedDate = nil
        timeSlots = []
        selectedSlotDatetime = nil
        Task { await loadDates(for: displayMonth) }
    }

    func didChangeMonth(_ month: Date) {
        displayMonth = month
        Task { await loadDates(for: month) }
    }

    func didSelectDate(_ date: Date) {
        // `selectedDate` is already updated by the calendar's binding.
        selectedSlotDatetime = nil
        Task { await loadSlots(for: date) }
    }

    func didSelectSlot(_ slot: AltegioBookingSlot) {
        selectedSlotDatetime = slot.datetime
    }

    func isSlotSelected(_ slot: AltegioBookingSlot) -> Bool {
        slot.datetime == selectedSlotDatetime
    }

    func didTapEditServices() {
        serviceIdsBeforeEdit = selectedServiceIds
        isEditingServices = true
    }

    func removeService(id: String) {
        // Always keep at least one service in the basket.
        guard selectedServiceIds.count > 1 else { return }
        selectedServiceIds.remove(id)
    }

    func onEditSheetDismissed() {
        guard selectedServiceIds != serviceIdsBeforeEdit else { return }
        // Editing the basket changes which masters / days / times are bookable.
        Task {
            showLoader()
            await loadMasters()
            await loadDates(for: displayMonth)
            if let selectedDate {
                await loadSlots(for: selectedDate, preselect: selectedSlotDatetime)
            }
            hideLoader()
        }
    }

    func didTapContinue() {
        guard canContinue, let datetime = selectedSlotDatetime else { return }
        transition.didContinue(salon, selectedServiceIds, selectedMasterId, datetime)
    }

    // MARK: - Bottom bar / edit sheet

    private var selectedServices: [SalonService] {
        salon.services
            .filter { selectedServiceIds.contains($0.id) }
            .sorted { ($0.sortOrder ?? .max) < ($1.sortOrder ?? .max) }
    }

    private var totalDurationMinutes: Int {
        selectedServices.reduce(0) { $0 + $1.durationMinutes }
    }

    private var totalPrice: Double {
        selectedServices.reduce(0) { $0 + $1.price }
    }

    var totalDurationText: String { Localization.salonDuration("\(totalDurationMinutes)") }
    var totalPriceText: String { Localization.bookingTotalPrice(formattedPrice(totalPrice)) }
    var editSheetTotalPriceText: String { Localization.priceUAH(formattedPrice(totalPrice)) }
    var selectedCountText: String { Localization.editServicesCount(selectedServiceIds.count) }

    /// The last remaining service can't be removed — the booking needs ≥ 1.
    var canRemoveServices: Bool { selectedServiceIds.count > 1 }

    var canContinue: Bool { selectedDate != nil && selectedSlotDatetime != nil }

    /// Forward calendar navigation is capped 6 months ahead of the current month.
    var maxNavigableMonth: Date {
        Self.calendar.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    }

    var addedServiceRows: [SelectServiceViewModel.AddedServiceModel] {
        selectedServices.map { service in
            SelectServiceViewModel.AddedServiceModel(
                id: service.id,
                name: service.name,
                duration: Localization.salonDuration("\(service.durationMinutes)"),
                price: Localization.priceUAH(formattedPrice(service.price))
            )
        }
    }

    // MARK: - Helpers

    private func formattedPrice(_ price: Double) -> String {
        price.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", price)
            : String(format: "%.2f", price)
    }

    // MARK: - Date / time formatting

    /// Gregorian / uk_UA calendar, matching `CalendarView` so the API's
    /// `yyyy-MM-dd` days line up with the grid's days.
    private static let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale(identifier: "uk_UA")
        return c
    }()

    private static let apiDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = calendar
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// `[dateFrom, dateTo]` for `month`, clamped so we never ask for past days.
    private static func monthRange(for month: Date) -> (from: String, to: String)? {
        guard let interval = calendar.dateInterval(of: .month, for: month),
              let lastOfMonth = calendar.date(byAdding: .day, value: -1, to: interval.end) else {
            return nil
        }
        let todayStart = calendar.startOfDay(for: Date())
        let from = max(interval.start, todayStart)
        return (apiDateFormatter.string(from: from), apiDateFormatter.string(from: lastOfMonth))
    }

    /// Calendar day from a datetime string's leading `yyyy-MM-dd` (handles both
    /// `2026-06-25T08:00:00+03:00` and `2026-06-25 08:00:00` shapes).
    private static func dayDate(from datetime: String) -> Date? {
        apiDateFormatter.date(from: String(datetime.prefix(10)))
    }

    /// `HH:mm` from a datetime string's chars 11–15, for the time-of-day fallback.
    private static func timeComponent(from datetime: String) -> String? {
        guard datetime.count >= 16 else { return nil }
        let start = datetime.index(datetime.startIndex, offsetBy: 11)
        let end = datetime.index(start, offsetBy: 5)
        return String(datetime[start..<end])
    }

    /// Match the carried datetime against the freshly loaded slots — by exact
    /// datetime first, then by time-of-day — and return the slot's own datetime.
    private static func resolvePreselectedSlot(_ datetime: String?, in slots: [AltegioBookingSlot]) -> String? {
        guard let datetime else { return nil }
        if let exact = slots.first(where: { $0.datetime == datetime }) {
            return exact.datetime
        }
        if let time = timeComponent(from: datetime),
           let byTime = slots.first(where: { $0.time == time }) {
            return byTime.datetime
        }
        return nil
    }
}
