import Foundation

// MARK: - SalonBookingProvider
//
// Which booking backend a salon is connected to. Drives how the "Book"
// CTA behaves: EasyWeek opens an external web widget, Altegio is booked
// in-app.

enum SalonBookingProvider {
    case easyweek
    case altegio
    case unknown

    init(rawValue: String?) {
        switch rawValue?.uppercased() {
        case "EASYWEEK": self = .easyweek
        case "ALTEGIO": self = .altegio
        default: self = .unknown
        }
    }
}
