import Foundation

// MARK: - WebBookingResult
//
// Emitted once the engine detects a completed booking in the widget. `bookingId`
// is the provider's booking id scraped from the completion page; `url` is the
// page it was detected on.

struct WebBookingResult: Equatable {
    let bookingId: String
    let url: URL?
}
