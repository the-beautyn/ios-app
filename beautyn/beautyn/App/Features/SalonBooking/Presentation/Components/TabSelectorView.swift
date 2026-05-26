import SwiftUI

// MARK: - TabSelectorView
//
// Matches Figma horizontal tab selector on the Salon Profile screen.
// e.g. Послуги | Спеціалісти | Відгуки (45) | Портфоліо | Деталі
// Active tab has an underline indicator.

struct TabSelectorView: View {

    let tabs: [String]
    @Binding var selectedIndex: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { index in
                    tabItem(title: tabs[index], index: index)
                }
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.App.blueTransparency)
                .frame(height: 1)
        }
    }

    @ViewBuilder
    private func tabItem(title: String, index: Int) -> some View {
        let isSelected = selectedIndex == index

        Button {
            selectedIndex = index
        } label: {
            VStack(spacing: 0) {
                Text(title)
                    .font(.App.footnote)
                    .foregroundStyle(isSelected ? Color.App.brown1 : Color.App.gray2)
                    .padding(.horizontal, CGFloat.Spacing.md)
                    .padding(.vertical, CGFloat.Spacing.sm)

                Rectangle()
                    .fill(isSelected ? Color.App.brown1 : Color.clear)
                    .frame(height: 2)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    @Previewable @State var selected = 0
    let tabs = ["Послуги", "Спеціалісти", "Відгуки (45)", "Портфоліо", "Деталі"]
    TabSelectorView(tabs: tabs, selectedIndex: $selected)
}
#endif
