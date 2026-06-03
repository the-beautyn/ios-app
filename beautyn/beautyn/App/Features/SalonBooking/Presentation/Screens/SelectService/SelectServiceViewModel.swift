import Combine
import Foundation
import SwiftUI

// MARK: - SelectServiceViewModel

@MainActor
final class SelectServiceViewModel: BaseViewModel {

    // MARK: - Category tab

    struct CategoryTab: Identifiable {
        let id: String
        let title: String
        let services: [SalonService]
    }

    // MARK: - Added service row (edit sheet)

    struct AddedServiceModel: Identifiable {
        let id: String
        let name: String
        let duration: String   // e.g. "90 хв."
        let price: String      // e.g. "700 грн"
    }

    // MARK: - Published State

    @Published var selectedCategoryIndex: Int = 0
    @Published var searchQueries: [String: String] = [:]
    @Published private(set) var selectedServiceIds: Set<String> = []
    @Published var isEditingServices: Bool = false

    /// Ids of services the salon can currently book given the selection + worker
    /// filter. Drives which services/categories are shown — unavailable ones are
    /// hidden. Seeded from the salon profile, refreshed on appear and whenever
    /// the selection changes.
    @Published private(set) var availableServiceIds: Set<String>

    /// Service id whose Add/Remove is currently resolving (availability re-fetch
    /// in flight). Drives that row's spinner and blocks other taps meanwhile.
    @Published private(set) var pendingServiceId: String?

    /// True while a toggle's availability re-fetch is in flight.
    var isToggling: Bool { pendingServiceId != nil }

    // MARK: - Dependencies

    private let salon: Salon
    private let entry: SalonBookingEntry
    private let getAltegioAvailableServicesUseCase: any GetAltegioAvailableServicesUseCase

    /// Specialist chosen on the salon profile (entry case 3). Not shown on this
    /// screen — carried forward to the upcoming date/time step, and used to
    /// filter availability here.
    private(set) var selectedWorkerId: String?

    /// Slot datetime chosen alongside the specialist (ISO 8601). Filters service
    /// availability by that datetime and is carried into later steps.
    private(set) var selectedDatetime: String?

    /// In-flight availability refresh; cancelled when a newer one starts.
    private var availabilityTask: Task<Void, Never>?

    private static let allCategoryId = "__all__"
    private static let otherCategoryId = "__other__"

    // MARK: - Init

    init(
        salon: Salon,
        entry: SalonBookingEntry,
        initialAvailableServiceIds: Set<String>,
        getAltegioAvailableServicesUseCase: any GetAltegioAvailableServicesUseCase
    ) {
        self.salon = salon
        self.entry = entry
        self.availableServiceIds = initialAvailableServiceIds
        self.getAltegioAvailableServicesUseCase = getAltegioAvailableServicesUseCase
        super.init()
        applyEntry(entry)
    }

    // MARK: - Lifecycle

    override func onViewTask() async {
        // Book entry reuses the set passed from the profile (no fetch) unless it
        // arrived empty — e.g. the profile's availability hadn't loaded yet.
        // Service / worker entries always refine with their filter. Routed
        // through the cancellable refresh so an early toggle can supersede it.
        switch entry {
        case .book:
            if availableServiceIds.isEmpty { scheduleAvailabilityRefresh() }
        case .service, .worker:
            scheduleAvailabilityRefresh()
        }
    }

    private func applyEntry(_ entry: SalonBookingEntry) {
        switch entry {
        case .book:
            break
        case .service(let id):
            selectedServiceIds.insert(id)
            if let index = categoryTabs.firstIndex(where: { tab in
                tab.services.contains { $0.id == id }
            }) {
                selectedCategoryIndex = index
            }
        case .worker(let id, let datetime):
            selectedWorkerId = id
            selectedDatetime = datetime
        }
    }

    // MARK: - Category building

    /// A service is shown when it is currently bookable, or already selected (so
    /// a picked service never disappears mid-flow).
    private func isServiceVisible(_ service: SalonService) -> Bool {
        availableServiceIds.contains(service.id) || selectedServiceIds.contains(service.id)
    }

    /// Built from the salon's services, filtered to the currently-visible ones.
    /// Categories with nothing left to show are dropped entirely (no tab).
    var categoryTabs: [CategoryTab] {
        let visibleServices = salon.services.filter { $0.isActive && isServiceVisible($0) }
        guard !visibleServices.isEmpty else { return [] }

        // No categories at all → a single "Послуги" tab with everything.
        guard !salon.categories.isEmpty else {
            return [CategoryTab(
                id: Self.allCategoryId,
                title: Localization.salonTabServices,
                services: visibleServices.sorted(by: Self.serviceOrder)
            )]
        }

        let sortedCategories = salon.categories.sorted {
            ($0.sortOrder ?? .max) < ($1.sortOrder ?? .max)
        }

        var tabs: [CategoryTab] = []
        var categorizedIds = Set<String>()

        for category in sortedCategories {
            let services = visibleServices
                .filter { $0.categoryId == category.id }
                .sorted(by: Self.serviceOrder)
            guard !services.isEmpty else { continue }
            categorizedIds.formUnion(services.map { $0.id })
            tabs.append(CategoryTab(id: category.id, title: category.name, services: services))
        }

        // Services with no / unmatched category → trailing "Інше" tab.
        let uncategorized = visibleServices
            .filter { !categorizedIds.contains($0.id) }
            .sorted(by: Self.serviceOrder)
        if !uncategorized.isEmpty {
            tabs.append(CategoryTab(
                id: Self.otherCategoryId,
                title: Localization.selectServiceOtherCategory,
                services: uncategorized
            ))
        }

        return tabs
    }

    private static func serviceOrder(_ lhs: SalonService, _ rhs: SalonService) -> Bool {
        let l = lhs.sortOrder ?? .max
        let r = rhs.sortOrder ?? .max
        return l != r ? l < r : lhs.name < rhs.name
    }

    // MARK: - Tabs / search

    var categoryTitles: [String] { categoryTabs.map(\.title) }

    func filteredServices(for tab: CategoryTab) -> [SalonService] {
        let q = (searchQueries[tab.id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return tab.services }
        return tab.services.filter { service in
            service.name.localizedCaseInsensitiveContains(q)
                || (service.description?.localizedCaseInsensitiveContains(q) ?? false)
        }
    }

    // Each category keeps its own search text, mirroring SalonProfile's per-tab
    // search. A fresh binding is produced per render; SwiftUI uses it transiently.
    func searchBinding(for tab: CategoryTab) -> Binding<String> {
        Binding(
            get: { self.searchQueries[tab.id] ?? "" },
            set: { self.searchQueries[tab.id] = $0 }
        )
    }

    // MARK: - Row models

    func serviceRowModel(for service: SalonService) -> ServiceModel {
        ServiceModel(
            id: service.id,
            name: service.name,
            description: service.description ?? "",
            photoURLs: service.imageUrls.compactMap(URL.init(string:)),
            price: Localization.salonPriceFrom(formattedPrice(service.price)),
            duration: Localization.salonDuration("\(service.durationMinutes)"),
            isAdded: selectedServiceIds.contains(service.id)
        )
    }

    var addedServiceRows: [AddedServiceModel] {
        selectedServices.map { service in
            AddedServiceModel(
                id: service.id,
                name: service.name,
                duration: Localization.salonDuration("\(service.durationMinutes)"),
                price: Localization.priceUAH(formattedPrice(service.price))
            )
        }
    }

    // MARK: - Totals

    private var selectedServices: [SalonService] {
        salon.services
            .filter { selectedServiceIds.contains($0.id) }
            .sorted(by: Self.serviceOrder)
    }

    var hasSelection: Bool { !selectedServiceIds.isEmpty }
    var selectedCount: Int { selectedServiceIds.count }

    private var totalDurationMinutes: Int {
        selectedServices.reduce(0) { $0 + $1.durationMinutes }
    }

    private var totalPrice: Double {
        selectedServices.reduce(0) { $0 + $1.price }
    }

    var totalDurationText: String { Localization.salonDuration("\(totalDurationMinutes)") }
    var totalPriceText: String { Localization.bookingTotalPrice(formattedPrice(totalPrice)) }
    var editSheetTotalPriceText: String { Localization.priceUAH(formattedPrice(totalPrice)) }
    var selectedCountText: String { Localization.editServicesCount(selectedCount) }

    // MARK: - Intents

    func toggle(_ service: SalonService) {
        // One toggle resolves at a time — the list is blocked while its
        // availability is re-fetched, so ignore taps that slip through.
        guard pendingServiceId == nil else { return }
        if selectedServiceIds.contains(service.id) {
            selectedServiceIds.remove(service.id)
        } else {
            selectedServiceIds.insert(service.id)
        }
        // Spin this row + block the list until the CRM confirms what's still
        // compatible, so the user can't pick a service that's about to vanish.
        pendingServiceId = service.id
        scheduleAvailabilityRefresh()
    }

    func removeService(id: String) {
        selectedServiceIds.remove(id)
        if selectedServiceIds.isEmpty { isEditingServices = false }
        // Refreshed in the background — the edit sheet covers the list, so this
        // path doesn't block or spin a row.
        scheduleAvailabilityRefresh()
    }

    // MARK: - Availability

    // Changing the basket (or the chosen worker) changes what else can be booked
    // alongside it, so re-ask the CRM and hide anything no longer compatible.
    private func scheduleAvailabilityRefresh() {
        availabilityTask?.cancel()
        availabilityTask = Task { [weak self] in
            await self?.performAvailabilityFetch()
        }
    }

    private func performAvailabilityFetch() async {
        do {
            let ids = try await getAltegioAvailableServicesUseCase.execute(
                salonId: salon.id,
                selectedServiceIds: Array(selectedServiceIds),
                workerId: selectedWorkerId,
                datetime: selectedDatetime
            )
            try Task.checkCancellation()
            // Keep selected services visible even if the CRM omits them. Animate
            // the change so rows/tabs fade in and out instead of snapping when
            // the list reloads.
            withAnimation(.easeInOut(duration: 0.25)) {
                availableServiceIds = ids.union(selectedServiceIds)
            }
            clampSelectedCategoryIndex()
            pendingServiceId = nil
        } catch is CancellationError {
            // Superseded by a newer refresh — let that one own the pending marker.
        } catch {
            pendingServiceId = nil
            showError(error)
        }
    }

    // Tabs can disappear when their services become unavailable; keep the paged
    // selection within range so the screen never lands on a removed tab.
    private func clampSelectedCategoryIndex() {
        let count = categoryTabs.count
        guard count > 0 else { return }
        selectedCategoryIndex = min(max(selectedCategoryIndex, 0), count - 1)
    }

    func didTapEditServices() {
        guard hasSelection else { return }
        isEditingServices = true
    }

    func didTapContinue() {
        // Mocked until the date/time step exists.
        showComingSoon()
    }

    // MARK: - Private

    private func showComingSoon() {
        showSuccess(
            title: Localization.salonProfileComingSoonTitle,
            message: Localization.salonProfileComingSoonMessage,
            scope: .current
        )
    }

    private func formattedPrice(_ price: Double) -> String {
        price.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", price)
            : String(format: "%.2f", price)
    }
}
