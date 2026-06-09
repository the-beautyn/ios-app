import Foundation

// MARK: - BookingCardFormatter
//
// Builds the presentation `AppointmentCardModel` from a domain `Booking`,
// formatting date / time / price / duration the way the Figma cards show them.
// A live map is only attached for the upcoming tab (`showMap`), and that tab
// uses relative day names ("Завтра" / "Сьогодні").

enum BookingCardFormatter {

    static func make(_ booking: Booking, showMap: Bool, relativeDay: Bool) -> AppointmentCardModel {
        AppointmentCardModel(
            id: booking.id,
            salonName: booking.salonName,
            address: booking.salonAddress ?? "",
            salonImageURL: booking.salonImageURL,
            date: AppointmentDateFormatter.dateString(booking.datetime, relativeDay: relativeDay, timeZone: booking.timezone),
            time: AppointmentDateFormatter.timeString(start: booking.datetime, end: booking.endDatetime, timeZone: booking.timezone),
            price: priceString(booking),
            duration: durationString(booking),
            serviceName: booking.serviceNames.isEmpty ? nil : booking.serviceNames.joined(separator: ", "),
            coordinate: showMap ? booking.coordinate : nil
        )
    }

    // MARK: - Price / duration

    private static func priceString(_ booking: Booking) -> String {
        guard let price = booking.totalPrice, price > 0 else { return "" }
        let amount = formattedAmount(price)
        if let currency = booking.currency, !isUAH(currency) {
            return "\(amount) \(currency)"
        }
        return Localization.homeAppointmentPrice(amount)
    }

    private static func durationString(_ booking: Booking) -> String {
        guard let minutes = booking.durationMinutes, minutes > 0 else { return "" }
        return Localization.homeAppointmentDuration("\(minutes)")
    }

    private static func formattedAmount(_ value: Double) -> String {
        let rounded = value.rounded()
        if abs(value - rounded) < 0.01 {
            return String(Int(rounded))
        }
        return String(format: "%.2f", value)
    }

    private static func isUAH(_ currency: String) -> Bool {
        let normalized = currency.uppercased()
        return normalized == "UAH" || currency == "грн" || normalized == "₴"
    }
}
