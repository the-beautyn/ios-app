import Foundation

struct WebPagePresentation: Identifiable {
    let id = UUID()
    let url: URL
    let title: String?
    /// Fired when the user dismisses the sheet (Done / swipe). Lets the presenter
    /// react to the close — e.g. Booking Details re-syncs the booking from the CRM
    /// after the "Внести зміни" page closes.
    let onDismiss: (() -> Void)?
}
