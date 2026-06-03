import SwiftUI

// MARK: - SelectDateTimeView
//
// Booking step matching Figma node 143:3026 ("Оберіть час та дату"). Composes the
// pre-built master picker, calendar and time-slot pills with the shared
// total-price bottom bar:
// - `MasterPickerView` — horizontal master avatars ("Будь-який" first).
// - `CalendarView` — month grid; available days come from the dates API.
// - `TimeSlotView` row — slots for the selected day.

struct SelectDateTimeView: BaseViewProtocol {

    @StateObject var viewModel: SelectDateTimeViewModel

    var contentView: some View {
        VStack(spacing: CGFloat.Spacing.md) {
            MasterPickerView(
                masters: viewModel.masters,
                selectedMasterId: viewModel.masterSelection
            )
            .padding(.top, CGFloat.Spacing.md)

            CalendarView(
                selectedDate: $viewModel.selectedDate,
                availableDates: viewModel.availableDates,
                maxMonth: viewModel.maxNavigableMonth,
                initialMonth: viewModel.initialMonth,
                onMonthChanged: { viewModel.didChangeMonth($0) },
                onDateSelected: { viewModel.didSelectDate($0) }
            )
            .padding(.horizontal, CGFloat.Spacing.md)
            .opacity(viewModel.isLoadingDates ? 0.5 : 1)

            separator

            timeSlots

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.App.white)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SelectServiceBottomBar(
                totalDurationText: viewModel.totalDurationText,
                totalPriceText: viewModel.totalPriceText,
                canEdit: true,
                canContinue: viewModel.canContinue,
                onEdit: viewModel.didTapEditServices,
                onContinue: viewModel.didTapContinue
            )
        }
        .sheet(isPresented: $viewModel.isEditingServices, onDismiss: viewModel.onEditSheetDismissed) {
            EditServicesSheet(
                countText: viewModel.selectedCountText,
                totalDurationText: viewModel.totalDurationText,
                totalPriceText: viewModel.editSheetTotalPriceText,
                services: viewModel.addedServiceRows,
                canRemove: viewModel.canRemoveServices,
                onRemove: { viewModel.removeService(id: $0) },
                onClose: { viewModel.isEditingServices = false }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(32)
        }
    }

    // MARK: - Separator

    private var separator: some View {
        Rectangle()
            .fill(Color.App.blueTransparency)
            .frame(height: 1)
            .padding(.horizontal, CGFloat.Spacing.md)
    }

    // MARK: - Time slots

    @ViewBuilder
    private var timeSlots: some View {
        if viewModel.isLoadingSlots {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, CGFloat.Spacing.md)
        } else if !viewModel.timeSlots.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CGFloat.Spacing.sm) {
                    ForEach(viewModel.timeSlots, id: \.datetime) { slot in
                        TimeSlotView(
                            time: slot.time,
                            isSelected: viewModel.isSlotSelected(slot),
                            onTap: { viewModel.didSelectSlot(slot) }
                        )
                    }
                }
                // Keep the pills' 1pt stroke from being shaved by the scroll view.
                .padding(.vertical, 2)
                .padding(.horizontal, CGFloat.Spacing.md)
            }
        } else if viewModel.selectedDate != nil {
            Text(Localization.salonProfileNothingFound)
                .font(.App.subheadline)
                .foregroundStyle(Color.App.gray2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, CGFloat.Spacing.md)
        }
    }
}

// MARK: - Preview

#if DEBUG

private final class PreviewWorkersUseCase: GetAltegioAvailableWorkersUseCase {
    func execute(salonId: String, serviceIds: [String], datetime: String?, includeSlots: Bool) async throws -> [AltegioBookableWorker] {
        [
            AltegioBookableWorker(id: "w1", isBookable: true, slots: []),
            AltegioBookableWorker(id: "w2", isBookable: true, slots: [])
        ]
    }
}

private final class PreviewDatesUseCase: GetAltegioBookingDatesUseCase {
    func execute(salonId: String, serviceIds: [String], workerId: String?, dateFrom: String, dateTo: String) async throws -> [Date] {
        let cal = Calendar(identifier: .gregorian)
        return (1...8).compactMap { cal.date(byAdding: .day, value: $0 * 2, to: Date()) }
    }
}

private final class PreviewTimeSlotsUseCase: GetAltegioTimeSlotsUseCase {
    func execute(salonId: String, date: String, workerId: String?, serviceIds: [String]) async throws -> [AltegioBookingSlot] {
        ["08:00", "08:20", "09:20", "11:00", "12:20"].map {
            AltegioBookingSlot(time: $0, datetime: "\(date)T\($0):00", date: nil, seanceLengthSec: 1800, sumLengthSec: 1800)
        }
    }
}

@MainActor
private func makePreviewVM() -> SelectDateTimeViewModel {
    let services = [
        SalonService(id: "srv1", salonId: "s1", categoryId: "c1", name: "Classic Manicure", description: nil, durationMinutes: 90, price: 700, currency: "UAH", isActive: true, sortOrder: 0, workerIds: [], imageUrls: []),
        SalonService(id: "srv2", salonId: "s1", categoryId: "c1", name: "French Manicure", description: nil, durationMinutes: 90, price: 700, currency: "UAH", isActive: true, sortOrder: 1, workerIds: [], imageUrls: [])
    ]
    let salon = Salon(
        id: "s1", name: "Beauty Studio Kyiv", provider: .altegio, bookingUrl: nil,
        addressLine: nil, city: "Київ", phone: nil, description: nil, coverImageUrl: nil,
        imageUrls: [], ratingAvg: 4.8, ratingCount: 85, workingSchedule: nil,
        topMastersTag: nil, isSaved: false, services: services,
        workers: [
            SalonWorker(id: "w1", firstName: "Ashley", lastName: "Brown", position: "Майстер манікюру", description: nil, photoUrl: nil),
            SalonWorker(id: "w2", firstName: "Amber", lastName: "Lee", position: "Майстер манікюру", description: nil, photoUrl: nil)
        ],
        categories: []
    )
    return SelectDateTimeViewModel(
        salon: salon,
        selectedServiceIds: ["srv1", "srv2"],
        workerId: nil,
        datetime: nil,
        getAltegioAvailableWorkersUseCase: PreviewWorkersUseCase(),
        getAltegioBookingDatesUseCase: PreviewDatesUseCase(),
        getAltegioTimeSlotsUseCase: PreviewTimeSlotsUseCase()
    )
}

#Preview {
    NavigationStack {
        SelectDateTimeView(viewModel: makePreviewVM())
            .navigationTitle(Localization.bookingDatePickerTitle)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#endif
