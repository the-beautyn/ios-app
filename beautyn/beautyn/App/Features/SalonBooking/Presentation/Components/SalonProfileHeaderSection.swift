import SwiftUI

// MARK: - SalonProfileHeaderSection
//
// The first block of the rounded white sheet on the SalonProfile screen:
// optional tag badge, salon name + rating, address, working schedule.
// The tag row is omitted entirely when nil so the layout tightens — no
// reserved empty space.

struct SalonProfileHeaderSection: View {

    let tag: String?
    let name: String
    let rating: Double?
    let address: String?
    let workingSchedule: String?

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
            if let tag {
                TagBadgeView(text: tag)
            }

            HStack(alignment: .firstTextBaseline) {
                Text(name)
                    .font(.App.title2Medium)
                    .tracking(CGFloat.Tracking.title2)
                    .foregroundStyle(Color.App.text)

                Spacer(minLength: CGFloat.Spacing.sm)

                if let rating {
                    RatingBadgeView(rating: rating)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                if let address, !address.isEmpty {
                    Text(address)
                        .font(.App.caption2)
                        .tracking(CGFloat.Tracking.caption2)
                        .foregroundStyle(Color.App.gray)
                }

                if let workingSchedule, !workingSchedule.isEmpty {
                    Text(workingSchedule)
                        .font(.App.caption2)
                        .tracking(CGFloat.Tracking.caption2)
                        .foregroundStyle(Color.App.gray)
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("With tag") {
    SalonProfileHeaderSection(
        tag: "Top 10 Masters",
        name: "Nail bar: Glossy Room",
        rating: 4.5,
        address: "вул. Зеленицька, 15, 05-091",
        workingSchedule: "ПН – ВС, 12:00 — 20:00"
    )
    .padding()
}

#Preview("Without tag") {
    SalonProfileHeaderSection(
        tag: nil,
        name: "Nail bar: Glossy Room",
        rating: 4.5,
        address: "вул. Зеленицька, 15, 05-091",
        workingSchedule: "ПН – ВС, 12:00 — 20:00"
    )
    .padding()
}
#endif
