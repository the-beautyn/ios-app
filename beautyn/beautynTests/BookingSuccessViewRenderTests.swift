import SwiftUI
import XCTest
@testable import beautyn

// MARK: - BookingSuccessViewRenderTests
//
// Renders the actual BookingSuccessView (brand logo + "Вас успішно записано" on a
// fog-grey background) to a PNG for visual verification against Figma
// 7nmKybCJdJ84RCtY4D6ebK:143:3199. The view model's 2.5s auto-dismiss timer
// outlives the renderer's 0.5s capture window, so the splash is captured intact.
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
//     -only-testing:beautynTests/BookingSuccessViewRenderTests

@MainActor
final class BookingSuccessViewRenderTests: XCTestCase {

    func testRenderBookingSuccess() async throws {
        let view = BookingSuccessView(
            viewModel: BookingSuccessViewModel(transition: .init(didFinish: {}))
        )
        try await ViewRenderer.render(view, name: "booking_success")
    }
}
