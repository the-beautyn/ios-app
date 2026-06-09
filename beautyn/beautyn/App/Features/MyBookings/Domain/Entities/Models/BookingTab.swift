import Foundation

// MARK: - BookingTab
//
// The three segments of the My Bookings screen. Each maps to a backend status
// filter (see `GetMyBookingsUseCase`) and carries its own localized labels.

enum BookingTab: Int, CaseIterable, Identifiable {
    case upcoming
    case past
    case cancelled

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .upcoming: return Localization.bookingsTabUpcoming
        case .past: return Localization.bookingsTabPast
        case .cancelled: return Localization.bookingsTabCancelled
        }
    }

    var sectionTitle: String {
        switch self {
        case .upcoming: return Localization.bookingsUpcomingSectionTitle
        case .past: return Localization.bookingsPastSectionTitle
        case .cancelled: return Localization.bookingsCancelledSectionTitle
        }
    }

    var emptyMessage: String {
        switch self {
        case .upcoming: return Localization.bookingsEmptyUpcoming
        case .past: return Localization.bookingsEmptyPast
        case .cancelled: return Localization.bookingsEmptyCancelled
        }
    }
}
