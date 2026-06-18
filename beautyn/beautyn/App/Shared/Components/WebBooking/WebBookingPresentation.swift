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
    /// CRM id of the booking being changed (EasyWeek reschedule) — excluded when
    /// scraping the new id so we don't re-capture the old one. `nil` for a new booking.
    let excludeBookingId: String?
    let onCompleted: (WebBookingResult) -> Void
    /// Fired when the user dismisses the sheet WITHOUT completing a booking (i.e.
    /// `onCompleted` never ran). Lets the presenter treat a plain close as
    /// "edited/cancelled" — e.g. re-sync the existing booking from the CRM. Not
    /// fired when the sheet is dismissed programmatically after a completion.
    let onDismiss: (() -> Void)?
}
