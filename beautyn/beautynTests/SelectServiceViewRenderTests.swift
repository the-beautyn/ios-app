import SwiftUI
import XCTest
@testable import beautyn

// MARK: - SelectServiceViewRenderTests
//
// Renders the actual SelectServiceView (+ EditServicesSheet) with mock Altegio
// data to PNG files for visual verification against Figma in file
// 7nmKybCJdJ84RCtY4D6ebK:
//   • SelectService            143:3336
//   • Preselected state        143:3411
//   • Edit-services sheet      143:3223
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
//     -only-testing:beautynTests/SelectServiceViewRenderTests

@MainActor
final class SelectServiceViewRenderTests: XCTestCase {

    // MARK: - Empty (entered via "Записатись")

    func testRenderSelectServiceEmpty() async throws {
        let view = SelectServiceView(viewModel: self.makeViewModel(entry: .book))
        try await ViewRenderer.render(view, name: "select_service_empty")
    }

    // MARK: - Preselected services (entered via a service row)

    func testRenderSelectServicePreselected() async throws {
        let viewModel = self.makeViewModel(entry: .service(id: "srv1"))
        // Add a second service so totals + multiple checkmarks are visible.
        viewModel.toggle(Salon.selectServicePreview.services[1])
        let view = SelectServiceView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "select_service_preselected")
    }

    // MARK: - Edit-services sheet (rendered standalone — a .sheet modal is not
    // captured by the hosting-controller snapshot)

    func testRenderEditServicesSheet() async throws {
        let view = EditServicesSheet(
            countText: Localization.editServicesCount(3),
            totalDurationText: Localization.salonDuration("225"),
            totalPriceText: Localization.priceUAH("2100"),
            services: [
                .init(id: "1", name: "Classic Manicure", duration: "90 хв.", price: "700 грн"),
                .init(id: "2", name: "French Manicure", duration: "120 хв.", price: "900 грн"),
                .init(id: "3", name: "Nail Art", duration: "15 хв.", price: "500 грн")
            ],
            onRemove: { _ in },
            onClose: {}
        )
        .frame(width: 393, height: 480)
        try await ViewRenderer.render(view, name: "select_service_edit_sheet")
    }

    // MARK: - Helpers

    private func makeViewModel(entry: SalonBookingEntry) -> SelectServiceViewModel {
        let ids = Set(Salon.selectServicePreview.services.map { $0.id })
        return SelectServiceViewModel(
            salon: .selectServicePreview,
            entry: entry,
            initialAvailableServiceIds: ids,
            getAltegioAvailableServicesUseCase: StubGetAltegioAvailableServicesUseCase(ids: ids)
        )
    }
}

// MARK: - Stub

private final class StubGetAltegioAvailableServicesUseCase: GetAltegioAvailableServicesUseCase {
    let ids: Set<String>
    init(ids: Set<String>) { self.ids = ids }
    func execute(salonId: String, selectedServiceIds: [String], workerId: String?, datetime: String?) async throws -> Set<String> { ids }
}

// MARK: - Preview Data

private extension Salon {

    static let selectServicePreview = Salon(
        id: "s1",
        name: "Beauty Studio Kyiv",
        provider: .altegio,
        bookingUrl: nil,
        addressLine: "вул. Франка, 10",
        city: "Київ",
        phone: nil,
        description: nil,
        coverImageUrl: nil,
        imageUrls: [],
        ratingAvg: 4.8,
        ratingCount: 85,
        workingSchedule: nil,
        topMastersTag: nil,
        isSaved: false,
        services: selectServiceServices,
        workers: [
            SalonWorker(id: "w1", firstName: "Ashley", lastName: "Brown", position: "Майстер манікюру", description: nil, photoUrl: nil)
        ],
        categories: selectServiceCategories
    )

    static let selectServiceCategories: [SalonCategory] = [
        SalonCategory(id: "c1", salonId: "s1", name: "Манікюр", color: nil, sortOrder: 0, serviceIds: []),
        SalonCategory(id: "c2", salonId: "s1", name: "Педікюр", color: nil, sortOrder: 1, serviceIds: []),
        SalonCategory(id: "c3", salonId: "s1", name: "One Time", color: nil, sortOrder: 2, serviceIds: []),
        SalonCategory(id: "c4", salonId: "s1", name: "Догляд", color: nil, sortOrder: 3, serviceIds: [])
    ]

    static let selectServiceServices: [SalonService] = [
        SalonService(id: "srv1", salonId: "s1", categoryId: "c1", name: "Classic Manicure", description: "Охайна форма, кутикула, легкий саге та базове покриття.", durationMinutes: 90, price: 700, currency: "UAH", isActive: true, sortOrder: 0, workerIds: [], imageUrls: []),
        SalonService(id: "srv2", salonId: "s1", categoryId: "c1", name: "French Manicure", description: "Класичний французький манікюр із гель-лаком.", durationMinutes: 120, price: 900, currency: "UAH", isActive: true, sortOrder: 1, workerIds: [], imageUrls: []),
        SalonService(id: "srv3", salonId: "s1", categoryId: "c1", name: "Nail Art", description: nil, durationMinutes: 15, price: 500, currency: "UAH", isActive: true, sortOrder: 2, workerIds: [], imageUrls: []),
        SalonService(id: "srv4", salonId: "s1", categoryId: "c2", name: "Pedicure Express", description: "Швидкий педикюр із покриттям.", durationMinutes: 60, price: 600, currency: "UAH", isActive: true, sortOrder: 0, workerIds: [], imageUrls: []),
        SalonService(id: "srv5", salonId: "s1", categoryId: "c3", name: "One Time Service", description: "Разова послуга.", durationMinutes: 45, price: 800, currency: "UAH", isActive: true, sortOrder: 0, workerIds: [], imageUrls: []),
        SalonService(id: "srv6", salonId: "s1", categoryId: "c4", name: "Догляд за нігтями", description: "Парафінотерапія та зволоження.", durationMinutes: 30, price: 400, currency: "UAH", isActive: true, sortOrder: 0, workerIds: [], imageUrls: [])
    ]
}
