import Foundation

// MARK: - SalonBookingEntry
//
// How the user entered the in-app (Altegio) booking flow from the salon
// profile. Threaded from `SalonProfileViewModel` through the coordinator into
// `SelectServiceViewModel` so the service-selection screen can preselect the
// right service / category or remember the chosen specialist for later steps.

enum SalonBookingEntry {
    /// Tapped the "Записатись" CTA — nothing preselected.
    case book
    /// Tapped a service row — preselect that service and open its category tab.
    case service(id: String)
    /// Tapped a specialist — no service preselected, but remember the worker and
    /// the chosen slot's `datetime` (when one was selected) so service
    /// availability can be filtered by that datetime too.
    case worker(id: String, datetime: String?)
}
