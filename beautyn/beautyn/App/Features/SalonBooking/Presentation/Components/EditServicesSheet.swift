import SwiftUI

// MARK: - EditServicesSheet
//
// Bottom sheet listing the services currently in the basket ("Додані послуги").
// Each row can be removed; the change is reflected live in the list behind it.
// Header shows the count + total time; the footer shows the total price.

struct EditServicesSheet: View {

    let countText: String           // e.g. "2 послуги"
    let totalDurationText: String    // e.g. "90 хв."
    let totalPriceText: String       // e.g. "1550 грн"
    let services: [SelectServiceViewModel.AddedServiceModel]
    /// When false, rows hide their remove (×) button — used to block removing
    /// the last service when the flow requires at least one.
    var canRemove: Bool = true
    let onRemove: (String) -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, CGFloat.Spacing.md)

            countRow

            Rectangle()
                .fill(Color.App.blueTransparency)
                .frame(height: 1)
                .padding(.horizontal, CGFloat.Spacing.md)

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(services) { service in
                        row(service)
                    }
                }
            }

            footer
        }
        .background(Color.App.white)
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text(Localization.editServicesTitle)
                .font(.App.headline)
                .foregroundStyle(Color.App.black)

            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.App.text)
                        .frame(width: 36, height: 36)
                        .background(Color.App.gray.opacity(0.08), in: Circle())
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .padding(.horizontal, CGFloat.Spacing.md)
    }

    // MARK: - Count row

    private var countRow: some View {
        HStack(alignment: .center) {
            Text(countText)
                .font(.App.headline)
                .foregroundStyle(Color.App.text)

            Spacer()

            Text(totalDurationText)
                .font(.App.caption1)
                .foregroundStyle(Color.App.gray2)
        }
        .padding(.horizontal, CGFloat.Spacing.md)
        .padding(.vertical, CGFloat.Spacing.sm + CGFloat.Spacing.xs)
    }

    // MARK: - Service row

    private func row(_ service: SelectServiceViewModel.AddedServiceModel) -> some View {
        HStack(alignment: .center, spacing: CGFloat.Spacing.sm) {
            VStack(alignment: .leading, spacing: CGFloat.Spacing.xxs) {
                Text(service.name)
                    .font(.App.footnote)
                    .foregroundStyle(Color.App.black)

                Text(service.duration)
                    .font(.App.caption2)
                    .tracking(CGFloat.Tracking.caption2)
                    .foregroundStyle(Color.App.gray2)
            }

            Spacer()

            Text(service.price)
                .font(.App.footnote)
                .foregroundStyle(Color.App.black)

            if canRemove {
                Button {
                    onRemove(service.id)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(Color.App.gray2)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, CGFloat.Spacing.sm)
        .padding(.horizontal, CGFloat.Spacing.md)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Text(Localization.editServicesTotal)
                .font(.App.footnoteSemibold)
                .foregroundStyle(Color.App.black)

            Spacer()

            Text(totalPriceText)
                .font(.App.footnoteSemibold)
                .foregroundStyle(Color.App.black)
        }
        .padding(.horizontal, CGFloat.Spacing.md)
        .padding(.vertical, CGFloat.Spacing.md)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.App.blueTransparency)
                .frame(height: 1)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    Color.App.beige2
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            EditServicesSheet(
                countText: "2 послуги",
                totalDurationText: "90 хв.",
                totalPriceText: "1550 грн",
                services: [
                    .init(id: "1", name: "Classic Manicure", duration: "90 хв.", price: "700 грн"),
                    .init(id: "2", name: "Classic Manicure", duration: "90 хв.", price: "700 грн"),
                    .init(id: "3", name: "French", duration: "15 хв.", price: "150 грн")
                ],
                onRemove: { _ in },
                onClose: {}
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
}
#endif
