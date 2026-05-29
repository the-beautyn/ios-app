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

    // MARK: - Dependencies

    private let salon: Salon

    /// Specialist chosen on the salon profile (entry case 3). Not shown on this
    /// screen — carried forward to the upcoming date/time step.
    private(set) var selectedWorkerId: String?

    /// Categories with their active services. Immutable for the salon, so it is
    /// built once in `init`.
    let categoryTabs: [CategoryTab]

    private static let allCategoryId = "__all__"
    private static let otherCategoryId = "__other__"

    // MARK: - Init

    init(salon: Salon, entry: SalonBookingEntry) {
        self.salon = salon
        self.categoryTabs = Self.buildCategoryTabs(from: salon)
        super.init()
        applyEntry(entry)
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
        case .worker(let id):
            selectedWorkerId = id
        }
    }

    // MARK: - Category building

    private static func buildCategoryTabs(from salon: Salon) -> [CategoryTab] {
        let activeServices = salon.services.filter { $0.isActive }
        guard !activeServices.isEmpty else { return [] }

        // No categories at all → a single "Послуги" tab with everything.
        guard !salon.categories.isEmpty else {
            return [CategoryTab(
                id: allCategoryId,
                title: Localization.salonTabServices,
                services: activeServices.sorted(by: serviceOrder)
            )]
        }

        let sortedCategories = salon.categories.sorted {
            ($0.sortOrder ?? .max) < ($1.sortOrder ?? .max)
        }

        var tabs: [CategoryTab] = []
        var categorizedIds = Set<String>()

        for category in sortedCategories {
            let services = activeServices
                .filter { $0.categoryId == category.id }
                .sorted(by: serviceOrder)
            guard !services.isEmpty else { continue }
            categorizedIds.formUnion(services.map { $0.id })
            tabs.append(CategoryTab(id: category.id, title: category.name, services: services))
        }

        // Services with no / unmatched category → trailing "Інше" tab.
        let uncategorized = activeServices
            .filter { !categorizedIds.contains($0.id) }
            .sorted(by: serviceOrder)
        if !uncategorized.isEmpty {
            tabs.append(CategoryTab(
                id: otherCategoryId,
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
        if selectedServiceIds.contains(service.id) {
            selectedServiceIds.remove(service.id)
        } else {
            selectedServiceIds.insert(service.id)
        }
    }

    func removeService(id: String) {
        selectedServiceIds.remove(id)
        if selectedServiceIds.isEmpty { isEditingServices = false }
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
