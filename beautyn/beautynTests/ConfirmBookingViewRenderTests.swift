import SwiftUI
import XCTest
@testable import beautyn

// MARK: - ConfirmBookingViewRenderTests
//
// Renders the actual ConfirmBookingView (salon header, date/time, services +
// total, discount field + apply, comment, pinned Confirm button) with mock data
// to PNG files for visual verification against Figma
// 7nmKybCJdJ84RCtY4D6ebK:143:4979 ("Підтвердження запису").
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
//     -only-testing:beautynTests/ConfirmBookingViewRenderTests

@MainActor
final class ConfirmBookingViewRenderTests: XCTestCase {

    // MARK: - Default (empty discount + comment), mirrors the Figma reference.

    func testRenderConfirmBooking() async throws {
        let view = ConfirmBookingView(viewModel: self.makeViewModel())
        try await ViewRenderer.render(view, name: "confirm_booking")
    }

    // MARK: - Filled (discount code + comment typed in)

    func testRenderConfirmBookingFilled() async throws {
        let viewModel = self.makeViewModel()
        viewModel.discountCode = "BEAUTY10"
        viewModel.comment = "Будь ласка, без обрізання кутикули. Дякую!"
        let view = ConfirmBookingView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "confirm_booking_filled")
    }

    // MARK: - Helpers

    private func makeViewModel() -> ConfirmBookingViewModel {
        ConfirmBookingViewModel(
            salon: .confirmBookingPreview,
            selectedServiceIds: ["srv1", "srv2"],
            workerId: "w1",
            datetime: "2025-06-25T09:00:00+03:00",
            transition: .init(didFinishBooking: { _ in }),
            createBookingUseCase: StubCreateBookingUseCase(),
            getCurrentUserUseCase: StubCurrentUserUseCase()
        )
    }
}

// MARK: - Stubs

private final class StubCreateBookingUseCase: CreateAltegioBookingUseCase {
    func execute(salonId: String, workerId: String?, serviceIds: [String], datetime: String, comment: String?) async throws -> Booking {
        Booking(
            id: "booking-1", salonId: salonId, salonName: "Preview Salon", salonAddress: nil,
            salonImageURL: nil, coordinate: nil, bookingUrl: nil, crmType: .altegio, crmRecordId: nil, status: .created,
            datetime: Date(), endDatetime: nil, cancelledAt: nil, services: [],
            totalPrice: nil, currency: nil, durationMinutes: nil, timezone: nil
        )
    }
}

private final class StubCurrentUserUseCase: GetCurrentUserUseCase {
    func execute() async throws -> UserProfile {
        UserProfile(
            id: "u1", email: "helga.altuhova@gmail.com", role: "client", name: "Ольга",
            secondName: nil, phone: "+380506314634", avatarUrl: nil, birthDate: nil, city: nil,
            sex: nil, authProvider: "email", isPhoneVerified: true, isProfileCreated: true,
            isOnboardingCompleted: true
        )
    }
}

// MARK: - Preview Data

private extension Salon {

    static let confirmBookingPreview = Salon(
        id: "s1",
        name: "Nail bar: Glossy Room",
        provider: .altegio,
        bookingUrl: nil,
        addressLine: "вул. Зеленицька, 15, 05-091",
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
            SalonService(id: "srv2", salonId: "s1", categoryId: "c1", name: "French", description: nil, durationMinutes: 15, price: 150, currency: "UAH", isActive: true, sortOrder: 1, workerIds: [], imageUrls: [])
        ],
        workers: [
            SalonWorker(id: "w1", firstName: "Ashley", lastName: "Brown", position: "Майстер манікюру", description: nil, photoUrl: nil)
        ],
        categories: []
    )
}
