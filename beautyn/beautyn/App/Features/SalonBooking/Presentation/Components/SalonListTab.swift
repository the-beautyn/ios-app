import SwiftUI

// MARK: - SalonListTab
//
// Shared chrome for a single Salon Profile tab (Services / Specialists):
// a per-tab search field, a scrolling list of rows, and an empty state.
// Both tabs look identical apart from their row type, so the row content is
// supplied via a @ViewBuilder closure while the surrounding layout is reused.

struct SalonListTab<Rows: View>: View {

    let placeholder: String
    @Binding var searchText: String
    let isEmpty: Bool
    let emptyMessage: String
    // Bubbles the search field's focus state up so the parent can collapse the
    // cover and lift the sheet above the keyboard on compact screens.
    var onFocusChange: (Bool) -> Void = { _ in }
    @ViewBuilder var rows: () -> Rows

    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: CGFloat.Spacing.md) {
            SalonSearchField(
                placeholder: placeholder,
                text: $searchText,
                isFocused: $focused
            )
            .padding(.horizontal, CGFloat.Spacing.md)
            .onChange(of: focused) { _, isFocused in
                onFocusChange(isFocused)
            }

            if isEmpty {
                emptyLabel
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        rows()
                    }
                    .padding(.horizontal, CGFloat.Spacing.md)
                    .padding(.bottom, CGFloat.Spacing.md)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var emptyLabel: some View {
        Text(emptyMessage)
            .font(.App.subheadline)
            .foregroundStyle(Color.App.gray2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
