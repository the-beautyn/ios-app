import Foundation

// MARK: - BookingDetailsViewModel
//
// Placeholder for the booking details screen. Holds only the id for now; the
// real details UI will be built later.

@MainActor
final class BookingDetailsViewModel: BaseViewModel {

    let bookingId: String

    init(bookingId: String) {
        self.bookingId = bookingId
    }
}
