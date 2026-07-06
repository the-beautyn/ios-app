import SwiftUI

// MARK: - SearchDatePickerView
//
// Matches Figma "Оберіть дату" (143:8732, date section only — the time picker
// ships with a later iteration) — pushed inside the search sheet:
// back-arrow toolbar, the shared booking calendar, and the pinned
// Очистити/Застосувати bar.

struct SearchDatePickerView: BaseViewProtocol {

    @StateObject var viewModel: SearchDatePickerViewModel

    var contentView: some View {
        VStack(spacing: 0) {
            SearchSheetHeaderView(
                icon: "chevron.left",
                title: Localization.searchDatePickerTitle,
                onButtonTap: { viewModel.didTapBack() }
            )

            VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
                Text(Localization.bookingChooseDay)
                    .font(.App.headline)
                    .foregroundStyle(Color.App.text)
                    .padding(.vertical, CGFloat.Spacing.sm)

                CalendarView(
                    selectedDate: $viewModel.selectedDate,
                    initialMonth: viewModel.selectedDate
                )
            }
            .padding(.horizontal, CGFloat.Spacing.md)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.App.white)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
        }
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        // Figma 143:8854: two equal buttons, 12pt gap.
        HStack(spacing: CGFloat.Spacing.sm + CGFloat.Spacing.xs) {
            AppButton.secondaryOutlined(title: Localization.bookingClearButton) {
                viewModel.didTapClear()
            }

            AppButton(title: Localization.bookingApplyButton) {
                viewModel.didTapApply()
            }
        }
        .padding(.horizontal, CGFloat.Spacing.md)
        .padding(.top, CGFloat.Spacing.md)
        .padding(.bottom, CGFloat.Spacing.sm)
        .background(Color.App.white)
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
    let viewModel = SearchDatePickerViewModel(
        transition: .init(didTapBack: {}, didApply: { _ in }),
        initialDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())
    )
    SearchDatePickerView(viewModel: viewModel)
}
#endif
