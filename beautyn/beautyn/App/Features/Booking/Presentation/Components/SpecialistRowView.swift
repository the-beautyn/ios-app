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
    var onSelect: () -> Void

    private let avatarSize: CGFloat = 40

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
            HStack(spacing: CGFloat.Spacing.sm) {
                AsyncImage(url: specialist.imageURL) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    default:
                        Color.App.beige2
                            .overlay(Image(systemName: "person.fill").foregroundStyle(Color.App.brown2))
                    }
                }
                .frame(width: avatarSize, height: avatarSize)
                .clipShape(Circle())

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

                AppButton.secondaryOutlined(title: Localization.selectButton, size: .small, action: onSelect)
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
                }
            }
        }
        .padding(.vertical, CGFloat.Spacing.sm)
        .overlay(alignment: .bottom) { Divider() }
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
