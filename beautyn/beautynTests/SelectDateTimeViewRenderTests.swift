import SwiftUI
import XCTest
@testable import beautyn

// MARK: - SelectDateTimeViewRenderTests
//
// Renders the actual SelectDateTimeView (master picker + calendar + time slots +
// bottom bar) with mock Altegio data to PNG files for visual verification against
// Figma 7nmKybCJdJ84RCtY4D6ebK:143:3026 ("Оберіть час та дату").
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
//     -only-testing:beautynTests/SelectDateTimeViewRenderTests

@MainActor
final class SelectDateTimeViewRenderTests: XCTestCase {

    // MARK: - Empty (no date/time chosen upstream → nothing preselected)

    func testRenderSelectDateTimeEmpty() async throws {
        let view = SelectDateTimeView(viewModel: self.makeViewModel(workerId: nil, datetime: nil))
        try await ViewRenderer.render(view, name: "select_date_time_empty")
    }

    // MARK: - Preselected (master + day + slot carried from the salon profile),
    // mirroring the Figma: Ashley, 25th, 08:00.

    func testRenderSelectDateTimePreselected() async throws {
        let view = SelectDateTimeView(viewModel: self.makeViewModel(workerId: "w1", datetime: "2026-06-25T08:00:00"))
        try await ViewRenderer.render(view, name: "select_date_time_preselected")
    }

    // MARK: - Edit-services sheet with a single service (× hidden — can't remove last)

    func testRenderEditSheetSingleService() async throws {
        let view = EditServicesSheet(
            countText: Localization.editServicesCount(1),
            totalDurationText: Localization.salonDuration("60"),
            totalPriceText: Localization.priceUAH("350"),
            services: [.init(id: "1", name: "Haircut", duration: "60 хв.", price: "350 грн")],
            canRemove: false,
            onRemove: { _ in },
            onClose: {}
        )
        .frame(width: 393, height: 360)
        try await ViewRenderer.render(view, name: "edit_sheet_single_service")
    }

    // MARK: - Helpers

    private func makeViewModel(workerId: String?, datetime: String?) -> SelectDateTimeViewModel {
        SelectDateTimeViewModel(
            salon: .selectDateTimePreview,
            selectedServiceIds: ["srv1", "srv2"],
            workerId: workerId,
            datetime: datetime,
            getAltegioAvailableWorkersUseCase: StubWorkersUseCase(),
            getAltegioBookingDatesUseCase: StubDatesUseCase(),
            getAltegioTimeSlotsUseCase: StubTimeSlotsUseCase()
        )
    }
}

// MARK: - Stubs

private final class StubWorkersUseCase: GetAltegioAvailableWorkersUseCase {
    func execute(salonId: String, serviceIds: [String], datetime: String?, includeSlots: Bool) async throws -> [AltegioBookableWorker] {
        [
            AltegioBookableWorker(id: "w1", isBookable: true, slots: []),
            AltegioBookableWorker(id: "w2", isBookable: true, slots: []),
            AltegioBookableWorker(id: "w3", isBookable: true, slots: [])
        ]
    }
}

private final class StubDatesUseCase: GetAltegioBookingDatesUseCase {
    func execute(salonId: String, serviceIds: [String], workerId: String?, dateFrom: String, dateTo: String) async throws -> [Date] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        guard let start = formatter.date(from: dateFrom) else { return [] }
        let calendar = Calendar(identifier: .gregorian)
        // A handful of bookable days across the month (incl. the preselected 25th).
        return [0, 1, 3, 4, 7, 10, 11, 14, 17, 21, 22, 24, 27].compactMap {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
    }
}

private final class StubTimeSlotsUseCase: GetAltegioTimeSlotsUseCase {
    func execute(salonId: String, date: String, workerId: String?, serviceIds: [String]) async throws -> [AltegioBookingSlot] {
        ["08:00", "08:20", "09:20", "11:00", "12:20"].map {
            AltegioBookingSlot(time: $0, datetime: "\(date)T\($0):00", date: nil, seanceLengthSec: 1800, sumLengthSec: 1800)
        }
    }
}

// MARK: - Preview Data

private extension Salon {

    static let selectDateTimePreview = Salon(
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
        services: [
            SalonService(id: "srv1", salonId: "s1", categoryId: "c1", name: "Classic Manicure", description: nil, durationMinutes: 90, price: 700, currency: "UAH", isActive: true, sortOrder: 0, workerIds: [], imageUrls: []),
            SalonService(id: "srv2", salonId: "s1", categoryId: "c1", name: "French Manicure", description: nil, durationMinutes: 90, price: 700, currency: "UAH", isActive: true, sortOrder: 1, workerIds: [], imageUrls: [])
        ],
        workers: [
            SalonWorker(id: "w1", firstName: "Ashley", lastName: "Brown", position: "Майстер манікюру", description: nil, photoUrl: nil),
            SalonWorker(id: "w2", firstName: "Amber", lastName: "Lee", position: "Майстер манікюру", description: nil, photoUrl: nil),
            SalonWorker(id: "w3", firstName: "Sophia", lastName: "Reid", position: "Майстер педикюру", description: nil, photoUrl: nil)
        ],
        categories: []
    )
}
