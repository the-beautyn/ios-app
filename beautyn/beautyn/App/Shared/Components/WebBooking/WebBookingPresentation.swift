import Foundation

// MARK: - WebBookingPresentation
//
// Drives the interactive web-booking sheet (see `BaseViewModel.openWebBooking`).
// Mirrors `WebPagePresentation`, but additionally carries the provider
// configuration, the user's autofill details, and a completion callback fired
// when a booking is detected in the widget.

struct WebBookingPresentation: Identifiable {
    let id = UUID()
    let url: URL
    let title: String?
    let configuration: WebBookingConfiguration
    let autofill: WebBookingAutofill
    let onCompleted: (WebBookingResult) -> Void
}
