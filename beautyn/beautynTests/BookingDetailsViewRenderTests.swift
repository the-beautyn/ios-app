import Combine
import SwiftUI
import XCTest
@testable import beautyn

// MARK: - BookingDetailsViewRenderTests
//
// Renders the actual BookingDetailsView for each booking state to PNG files for
// visual verification against Figma 143:3861 / 143:5143 / 143:5082.
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
//     -only-testing:beautynTests/BookingDetailsViewRenderTests

@MainActor
final class BookingDetailsViewRenderTests: XCTestCase {

    func testRenderFuture() async throws {
        // Bind to a local first: BookingDetailsView's @StateObject init wraps the
        // argument in an autoclosure, so inlining makeViewModel() would capture self.
        let viewModel = makeViewModel(status: .created, datetime: Date().addingTimeInterval(86_400))
        let view = BookingDetailsView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "booking_details_future")
    }

    func testRenderPast() async throws {
        // Realistic past booking: the CRM leaves the stored status as "created", so
        // the screen must derive "past" from the elapsed datetime.
        let viewModel = makeViewModel(status: .created, datetime: Date().addingTimeInterval(-86_400))
        let view = BookingDetailsView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "booking_details_past")
    }

    func testRenderCancelled() async throws {
        let viewModel = makeViewModel(status: .canceled, datetime: Date().addingTimeInterval(-86_400))
        let view = BookingDetailsView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "booking_details_cancelled")
    }

    // MARK: - Helpers

    private func makeViewModel(status: BookingStatus, datetime: Date) -> BookingDetailsViewModel {
        BookingDetailsViewModel(
            booking: makeBooking(status: status, datetime: datetime),
            transition: .init(didTapBookAgain: { _ in }, didRequireAuth: {}),
            getSalonByIdUseCase: MockGetSalonByIdUseCase(),
            getSalonShareUseCase: MockGetSalonShareUseCase(),
            saveSalonUseCase: MockSaveSalonUseCase(),
            unsaveSalonUseCase: MockUnsaveSalonUseCase(),
            savedSalonsEventBus: MockSavedSalonsEventBus(),
            sessionManager: SessionManager(
                keychainService: KeychainServiceImpl(),
                defaultsService: DefaultsStorageService()
            )
        )
    }

    private func makeBooking(status: BookingStatus, datetime: Date) -> Booking {
        Booking(
            id: "b1",
            salonId: "s1",
            salonName: "Nail bar: Glossy Room",
            salonAddress: "вул. Зеленицька, 15 (411), 05-091",
            salonImageURL: nil,
            coordinate: nil,
            bookingUrl: URL(string: "https://beautyn.com.ua/b/abc123"),
            status: status,
            datetime: datetime,
            endDatetime: datetime.addingTimeInterval(5_400),
            services: [
                BookingService(
                    id: "srv1",
                    name: "Facial",
                    description: "Глибоке очищення, пілінг та зволожуюча маска для обличчя.",
                    price: 300
                ),
                BookingService(id: "srv2", name: "Royal shave", description: nil, price: 600),
            ],
            totalPrice: 900,
            currency: "UAH",
            durationMinutes: 90,
            timezone: TimeZone(identifier: "Europe/Kyiv")
        )
    }
}

// MARK: - Mocks

private final class MockGetSalonByIdUseCase: GetSalonByIdUseCase {
    func execute(id: String) async throws -> Salon { throw CancellationError() }
}

private final class MockGetSalonShareUseCase: GetSalonShareUseCase {
    func execute(id: String) async throws -> SalonShare {
        SalonShare(
            url: URL(string: "https://beautyn.com.ua/s/\(id)")!,
            title: "Nail bar: Glossy Room",
            description: nil
        )
    }
}

private final class MockSaveSalonUseCase: SaveSalonUseCase {
    func execute(salonId: String) async throws {}
}

private final class MockUnsaveSalonUseCase: UnsaveSalonUseCase {
    func execute(salonId: String) async throws {}
}

private final class MockSavedSalonsEventBus: SavedSalonsEventBus {
    var changes: AnyPublisher<SavedSalonChange, Never> { Empty().eraseToAnyPublisher() }
    func notify(_ change: SavedSalonChange) {}
}
