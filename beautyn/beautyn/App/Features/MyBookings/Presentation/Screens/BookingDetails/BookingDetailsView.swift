import SwiftUI

// MARK: - BookingDetailsView (placeholder)

struct BookingDetailsView: View {

    let bookingId: String

    var body: some View {
        VStack(spacing: CGFloat.Spacing.sm) {
            Text(Localization.bookingDetailsTitle)
                .font(.App.title2Medium)
                .tracking(CGFloat.Tracking.title2)
                .foregroundStyle(Color.App.text)

            Text(Localization.bookingDetailsComingSoon)
                .font(.App.body)
                .foregroundStyle(Color.App.gray2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CGFloat.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.App.backgroundLight)
    }
}
