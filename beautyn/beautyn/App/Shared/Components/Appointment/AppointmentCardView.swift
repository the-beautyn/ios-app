import SwiftUI
import CoreLocation

// MARK: - AppointmentCardModel

struct AppointmentCardModel: Identifiable {
    let id: String
    let salonName: String
    let address: String
    let salonImageURL: URL?
    let date: String            // e.g. "Середа, 25 Чер, 2025"
    let time: String            // e.g. "9:00 - 11:00"
    let price: String           // e.g. "700 грн"
    let duration: String        // e.g. "90 хв."
    var serviceName: String?    // e.g. "Classic Manicure, French" — shown in Bookings list
    var coordinate: CLLocationCoordinate2D?   // when set, a live map header is shown (upcoming bookings)
}

// MARK: - AppointmentCardView
//
// Shared card for the Home "next appointment" and the My Bookings list.
// Optional live-map header (upcoming bookings) + a footer action that is either
// a filled "Деталі" (details) or an outlined "Забронювати" (book) button.

struct AppointmentCardView: View {

    enum FooterAction {
        case details
        case book
    }

    let appointment: AppointmentCardModel
    var footerAction: FooterAction = .details
    var showsDivider: Bool = true
    var onCardTap: (() -> Void)? = nil
    var onFooterTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.xs) {
            if let coordinate = appointment.coordinate {
                BookingMapView(coordinate: coordinate)
                    .aspectRatio(346.0 / 199.0, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.bottom, CGFloat.Spacing.xs)
            }

            salonRow
            if showsDivider {
                Divider().padding(.vertical, CGFloat.Spacing.xs)
            }
            dateTimeRows
            footer
        }
        .padding(12)
        .contentShape(Rectangle())
        .onTapGesture { onCardTap?() }
        .background(Color.App.backgroundLight)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.App.blueTransparency, lineWidth: 1)
        )
    }

    // MARK: - Salon row

    private var salonRow: some View {
        HStack(spacing: CGFloat.Spacing.sm) {
            CachedImage(
                url: appointment.salonImageURL,
                size: CGSize(width: 68, height: 68),
                clipShape: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(appointment.salonName)
                    .font(.App.body)
                    .foregroundStyle(Color.App.black)
                    .lineLimit(1)

                Text(appointment.address)
                    .font(.App.subheadline)
                    .foregroundStyle(Color.App.gray.opacity(0.6))
                    .lineLimit(1)
            }
        }
    }

    // MARK: - Date & time rows

    private var dateTimeRows: some View {
        VStack(alignment: .leading, spacing: 0) {
            infoRow(icon: "calendar", text: appointment.date)
            infoRow(icon: "clock", text: appointment.time)
        }
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: CGFloat.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.App.gray2)
                .frame(width: 20, height: 20)

            Text(text)
                .font(.App.caption2)
                .tracking(CGFloat.Tracking.caption2)
                .foregroundStyle(Color.App.gray2)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            HStack(spacing: CGFloat.Spacing.sm) {
                Text(appointment.price)
                    .font(.App.caption1)
                    .foregroundStyle(Color.App.brown1)

                Text(appointment.duration)
                    .font(.App.caption1)
                    .foregroundStyle(Color.App.gray.opacity(0.5))

                if let service = appointment.serviceName {
                    Text(service)
                        .font(.App.caption2)
                        .tracking(CGFloat.Tracking.caption2)
                        .foregroundStyle(Color.App.gray2)
                        .lineLimit(1)
                }
            }

            Spacer()

            footerButton
        }
    }

    @ViewBuilder
    private var footerButton: some View {
        switch footerAction {
        case .details:
            Button(action: onFooterTap) {
                Text(Localization.detailsButton)
                    .font(.App.subheadline)
                    .foregroundStyle(Color.App.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.App.brown2, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
        case .book:
            Button(action: onFooterTap) {
                Text(Localization.bookingsBookButton)
                    .font(.App.subheadline)
                    .foregroundStyle(Color.App.brown1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.App.brown1, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview

#if DEBUG
private let previewAppointment = AppointmentCardModel(
    id: "1",
    salonName: "Nail bar: Glossy Room",
    address: "вул. Зеленицька, 15, 05-091",
    salonImageURL: nil,
    date: "Середа, 25 Чер, 2025",
    time: "9:00 - 11:00",
    price: "700 грн",
    duration: "90 хв.",
    serviceName: nil
)

#Preview("Home variant (no map)") {
    AppointmentCardView(appointment: previewAppointment, onFooterTap: {})
        .padding(CGFloat.Spacing.md)
}

#Preview("Upcoming (map + details)") {
    AppointmentCardView(
        appointment: AppointmentCardModel(
            id: "2",
            salonName: "Nail bar: Glossy Room",
            address: "вул. Зеленицька, 15, 05-091",
            salonImageURL: nil,
            date: "Завтра, 25 сер. 2025",
            time: "9:00 - 10:30",
            price: "700 грн",
            duration: "90 хв.",
            serviceName: "Classic Manicure, French",
            coordinate: CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234)
        ),
        footerAction: .details,
        onCardTap: {},
        onFooterTap: {}
    )
    .padding(CGFloat.Spacing.md)
}

#Preview("Past / cancelled (book)") {
    AppointmentCardView(
        appointment: AppointmentCardModel(
            id: "3",
            salonName: "Nail bar: Glossy Room",
            address: "вул. Зеленицька, 15, 05-091",
            salonImageURL: nil,
            date: "Середа, 25 Чер, 2025",
            time: "9:00 - 11:00",
            price: "700 грн",
            duration: "90 хв.",
            serviceName: "Classic Manicure, French"
        ),
        footerAction: .book,
        onCardTap: {},
        onFooterTap: {}
    )
    .padding(CGFloat.Spacing.md)
}
#endif
