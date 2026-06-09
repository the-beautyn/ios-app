import SwiftUI

// MARK: - BookingTabSelector
//
// Underlined segmented control for the My Bookings tabs (Наступні / Попередні /
// Скасовані). The active segment uses dark text + a dark underline; inactive
// segments are gray. A hairline divider spans the full width underneath.

struct BookingTabSelector: View {

    let tabs: [BookingTab]
    let selection: BookingTab
    var onSelect: (BookingTab) -> Void

    var body: some View {
        HStack(spacing: 28) {
            ForEach(tabs) { tab in
                segment(tab)
            }
            Spacer(minLength: 0)
        }
    }

    private func segment(_ tab: BookingTab) -> some View {
        let isSelected = tab == selection
        return Button {
            onSelect(tab)
        } label: {
            // The underline is a bottom overlay so it spans only the label width
            // (not a greedy sibling Rectangle), which also lets the HStack pack
            // the tabs to the leading edge instead of stretching them.
            Text(tab.title)
                .font(.App.footnote)
                .foregroundStyle(isSelected ? Color.App.brown1 : Color.App.gray2)
                .padding(.bottom, CGFloat.Spacing.sm)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(isSelected ? Color.App.brown1 : Color.clear)
                        .frame(height: 2)
                }
        }
        .buttonStyle(.plain)
    }
}
