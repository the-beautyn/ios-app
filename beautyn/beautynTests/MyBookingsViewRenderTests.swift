import CoreLocation
import SwiftUI
import XCTest
@testable import beautyn

// MARK: - MyBookingsViewRenderTests
//
// Renders the actual MyBookingsView with mock data to PNG files for visual
// verification. The mock use case returns preview bookings, which flow through
// the normal ViewModel lifecycle (onViewTask → load → states).
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
//     -only-testing:beautynTests/MyBookingsViewRenderTests

@MainActor
final class MyBookingsViewRenderTests: XCTestCase {

    func testRenderUpcoming() async throws {
        let view = MyBookingsView(viewModel: self.makeViewModel(bookings: .previews))
        try await ViewRenderer.render(view, name: "my_bookings_upcoming")
    }

    func testRenderPast() async throws {
        let viewModel = makeViewModel(bookings: .previews)
        viewModel.selectTab(.past)
        let view = MyBookingsView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "my_bookings_past")
    }

    func testRenderCancelled() async throws {
        let viewModel = makeViewModel(bookings: .previews)
        viewModel.selectTab(.cancelled)
        let view = MyBookingsView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "my_bookings_cancelled")
    }

    func testRenderEmpty() async throws {
        let view = MyBookingsView(viewModel: self.makeViewModel(bookings: []))
        try await ViewRenderer.render(view, name: "my_bookings_empty")
    }

    // MARK: - Helpers

    private func makeViewModel(bookings: [Booking]) -> MyBookingsViewModel {
        MyBookingsViewModel(
            transition: .init(
                didTapBookingDetails: { _ in },
                didTapBook: { _ in }
            ),
            getMyBookingsUseCase: MockGetMyBookingsUseCase(bookings: bookings),
            bookingEventBus: BookingEventBusImpl()
        )
    }
}

// MARK: - MockGetMyBookingsUseCase

private final class MockGetMyBookingsUseCase: GetMyBookingsUseCase {
    let bookings: [Booking]
    init(bookings: [Booking]) { self.bookings = bookings }

    func execute(tab: BookingTab) async throws -> [Booking] {
        bookings
    }
}

// MARK: - Preview Data

extension Array where Element == Booking {

    static let previews: [Booking] = [
        Booking(
            id: "b1",
            salonId: "s1",
            salonName: "Nail bar: Glossy Room",
            salonAddress: "вул. Зеленицька, 15, 05-091",
            salonImageURL: nil,
            coordinate: CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234),
            bookingUrl: nil,
            status: .created,
            datetime: Date().addingTimeInterval(86_400),
            endDatetime: Date().addingTimeInterval(86_400 + 5_400),
            services: [
                BookingService(id: "srv1", name: "Classic Manicure", description: nil, price: nil),
                BookingService(id: "srv2", name: "French", description: nil, price: nil),
            ],
            totalPrice: 700,
            currency: "UAH",
            durationMinutes: 90,
            timezone: TimeZone(identifier: "Europe/Kyiv")
        ),
        Booking(
            id: "b2",
            salonId: "s1",
            salonName: "Nail bar: Glossy Room",
            salonAddress: "вул. Зеленицька, 15, 05-091",
            salonImageURL: nil,
            coordinate: CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234),
            bookingUrl: nil,
            status: .created,
            datetime: Date().addingTimeInterval(2 * 86_400),
            endDatetime: Date().addingTimeInterval(2 * 86_400 + 5_400),
            services: [
                BookingService(id: "srv1", name: "Classic Manicure", description: nil, price: nil),
                BookingService(id: "srv2", name: "French", description: nil, price: nil),
            ],
            totalPrice: 700,
            currency: "UAH",
            durationMinutes: 90,
            timezone: TimeZone(identifier: "Europe/Kyiv")
        ),
    ]
}
