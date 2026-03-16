import SwiftUI

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
    var mapImageURL: URL?       // map thumbnail — shown in Bookings list
}

// MARK: - AppointmentCardView
//
// Matches Figma "AppointmentDetails" (Home) and booking list card (My Bookings).
// Optional map thumbnail at top for the Bookings list variant.

struct AppointmentCardView: View {

    let appointment: AppointmentCardModel
    var onDetailsTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let mapURL = appointment.mapImageURL {
                mapThumbnail(url: mapURL)
            }

            VStack(alignment: .leading, spacing: CGFloat.Spacing.xs) {
                salonRow
                Divider().padding(.vertical, CGFloat.Spacing.xs)
                dateTimeRows
                footer
            }
            .padding(12)
        }
        .background(Color.App.backgroundLight)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.App.blueTransparency, lineWidth: 1)
        )
    }

    // MARK: - Map thumbnail

    private func mapThumbnail(url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image): image.resizable().scaledToFill()
            default: Color.App.beige2
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .clipped()
    }

    // MARK: - Salon row

    private var salonRow: some View {
        HStack(spacing: CGFloat.Spacing.sm) {
            AsyncImage(url: appointment.salonImageURL) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                default: Color.App.beige2
                }
            }
            .frame(width: 68, height: 68)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

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
                        .font(.App.caption1)
                        .foregroundStyle(Color.App.gray.opacity(0.5))
                        .lineLimit(1)
                }
            }

            Spacer()

            Button(action: onDetailsTap) {
                Text(Localization.detailsButton)
                    .font(.App.subheadline)
                    .foregroundStyle(Color.App.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.App.brown2, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
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
    serviceName: nil,
    mapImageURL: nil
)

#Preview("Home variant (no map)") {
    AppointmentCardView(appointment: previewAppointment, onDetailsTap: {})
        .padding(CGFloat.Spacing.md)
}

#Preview("Bookings list variant (with map + service)") {
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
            mapImageURL: nil
        ),
        onDetailsTap: {}
    )
    .padding(CGFloat.Spacing.md)
}
#endif
