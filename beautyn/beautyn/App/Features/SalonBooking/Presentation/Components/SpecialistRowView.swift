import SwiftUI

// MARK: - SpecialistModel

struct SpecialistModel: Identifiable {
    let id: String
    let name: String
    let specialty: String
    let imageURL: URL?
    var availableTimeSlots: [String] = []
    var nearestDate: String? = nil     // e.g. "Найближча дата запису 12.11:"
}

// MARK: - SpecialistRowView
//
// Matches Figma specialist row on the Salon Profile "Спеціалісти" tab.
// Avatar + name + specialty + "Обрати" button.
// Optionally shows a nearest date label + time slots row.

struct SpecialistRowView: View {

    let specialist: SpecialistModel
    @Binding var selectedTimeSlot: String?
    var showsActionButton: Bool = true
    var onSelect: () -> Void

    private let avatarSize: CGFloat = 40
    // Figma card padding (12) — also used to inset the slots scroll content so
    // it lines up with the rest of the card at rest while scrolling edge-to-edge.
    private let cardPadding: CGFloat = CGFloat.Spacing.sm + CGFloat.Spacing.xs

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
            HStack(spacing: CGFloat.Spacing.sm) {
                CachedImage.avatar(
                    url: specialist.imageURL,
                    size: CGSize(width: avatarSize, height: avatarSize)
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(specialist.name)
                        .font(.App.subheadline)
                        .foregroundStyle(Color.App.text)

                    Text(specialist.specialty)
                        .font(.App.caption2)
                        .tracking(CGFloat.Tracking.caption2)
                        .foregroundStyle(Color.App.gray2)
                }

                Spacer()

                if showsActionButton {
                    AppButton.secondaryOutlined(title: Localization.selectButton, size: .small, action: onSelect)
                }
            }

            if let nearestDate = specialist.nearestDate {
                Text(nearestDate)
                    .font(.App.caption2)
                    .tracking(CGFloat.Tracking.caption2)
                    .foregroundStyle(Color.App.gray2)
            }

            if !specialist.availableTimeSlots.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: CGFloat.Spacing.sm) {
                        ForEach(specialist.availableTimeSlots, id: \.self) { slot in
                            TimeSlotView(
                                time: slot,
                                isSelected: selectedTimeSlot == slot,
                                onTap: { selectedTimeSlot = slot }
                            )
                        }
                    }
                    // The pills' 1pt stroke sits on the scroll content's edge, so
                    // the horizontal ScrollView would shave it top/bottom. A
                    // little vertical room inside the content keeps it intact.
                    .padding(.vertical, 2)
                    // Inset the content so pills line up with the card at rest…
                    .padding(.horizontal, cardPadding)
                }
                // …while the scroll view itself spans the full card width, so
                // pills scroll edge-to-edge instead of stopping at the padding.
                .padding(.horizontal, -cardPadding)
            }
        }
        .padding(cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.App.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.App.blueTransparency, lineWidth: 1)
        )
    }
}

// MARK: - AnySpecialistRowView
//
// "Будь-який" / "Any" specialist card on the Salon Profile "Спеціалісти" tab
// (Figma 143:3609). Ivory placeholder avatar + label + "Обрати" — selecting it
// starts booking without a specific specialist. No slots.

struct AnySpecialistRowView: View {

    var onSelect: () -> Void

    private let avatarSize: CGFloat = 40

    var body: some View {
        HStack(spacing: CGFloat.Spacing.sm) {
            ZStack {
                Circle().fill(Color.App.beige2)
                Image(systemName: "person.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.App.brown2)
            }
            .frame(width: avatarSize, height: avatarSize)

            Text(Localization.bookingAnyMaster)
                .font(.App.subheadline)
                .foregroundStyle(Color.App.text)
                .frame(maxWidth: .infinity, alignment: .leading)

            AppButton.secondaryOutlined(title: Localization.selectButton, size: .small, action: onSelect)
        }
        .padding(CGFloat.Spacing.sm + CGFloat.Spacing.xs)   // 12
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.App.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.App.blueTransparency, lineWidth: 1)
        )
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    @Previewable @State var selectedSlot: String? = "08:00"
    VStack(spacing: 0) {
        SpecialistRowView(
            specialist: SpecialistModel(
                id: "1",
                name: "Ashley",
                specialty: "Майстер манікюру",
                imageURL: nil,
                availableTimeSlots: ["08:00", "08:20", "09:20", "11:00", "12:20"],
                nearestDate: "Найближча дата запису 12.11:"
            ),
            selectedTimeSlot: $selectedSlot,
            onSelect: {}
        )
        SpecialistRowView(
            specialist: SpecialistModel(id: "2", name: "Amber", specialty: "Майстер манікюру", imageURL: nil),
            selectedTimeSlot: $selectedSlot,
            onSelect: {}
        )
    }
    .padding(.horizontal, CGFloat.Spacing.md)
}
#endif
