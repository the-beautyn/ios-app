import SwiftUI

// MARK: - AppTab

enum AppTab: CaseIterable {
    case home, search, bookings, profile

    var title: String {
        switch self {
        case .home:     return Localization.tabHome
        case .search:   return Localization.tabSearch
        case .bookings: return Localization.tabBookings
        case .profile:  return Localization.tabProfile
        }
    }

    var icon: String {
        switch self {
        case .home:     return "house"
        case .search:   return "magnifyingglass"
        case .bookings: return "calendar"
        case .profile:  return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home:     return "house.fill"
        case .search:   return "magnifyingglass"
        case .bookings: return "calendar"
        case .profile:  return "person.fill"
        }
    }
}

// MARK: - TabBarView
//
// Matches Figma "Tab Bar" (node 1:7307).
// Active tab: icon + label inside a rounded-rect pill (beige2 background).
// Inactive tab: icon + label in gray.

struct TabBarView: View {

    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabItem(tab)
            }
        }
        .padding(.horizontal, CGFloat.Spacing.sm)
        .padding(.top, CGFloat.Spacing.sm)
        .padding(.bottom, CGFloat.Spacing.xs)
        .background(Color.App.backgroundLight)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    @ViewBuilder
    private func tabItem(_ tab: AppTab) -> some View {
        let isSelected = selection == tab

        Button {
            selection = tab
        } label: {
            VStack(spacing: CGFloat.Spacing.xxs) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.App.brown1 : Color.App.gray2)

                Text(tab.title)
                    .font(isSelected ? .App.caption2 : .App.caption2)
                    .tracking(CGFloat.Tracking.caption2)
                    .foregroundStyle(isSelected ? Color.App.brown1 : Color.App.gray2)
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.vertical, CGFloat.Spacing.xs)
            .background(
                isSelected
                    ? RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.App.beige2)
                    : nil
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    VStack {
        Spacer()
        TabBarView(selection: .constant(.home))
    }
}
#endif
