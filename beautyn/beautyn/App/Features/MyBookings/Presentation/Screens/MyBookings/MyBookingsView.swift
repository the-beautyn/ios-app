import SwiftUI

// MARK: - MyBookingsView

struct MyBookingsView: BaseViewProtocol {

    @StateObject var viewModel: MyBookingsViewModel

    var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            title

            BookingTabSelector(
                tabs: BookingTab.allCases,
                selection: viewModel.selectedTab,
                onSelect: { tabSelection.wrappedValue = $0 }
            )
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.sm)

            Rectangle()
                .fill(Color.App.blueTransparency)
                .frame(height: 1)

            pagedContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.App.backgroundLight)
    }

    // Tab selection bound to a paged TabView. Writing it inside `withAnimation`
    // makes a tap slide the pages (matching a swipe) and crossfades the selector
    // underline; the same binding is driven by swipes, keeping both in sync.
    private var tabSelection: Binding<BookingTab> {
        Binding(
            get: { viewModel.selectedTab },
            set: { newTab in
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.selectTab(newTab)
                }
            }
        )
    }

    // MARK: - Title

    private var title: some View {
        Text(Localization.bookingsTitle)
            .font(.App.title1Medium)
            .tracking(CGFloat.Tracking.title1)
            .foregroundStyle(Color.App.black)
            .padding(.horizontal, CGFloat.Spacing.md)
            // Match the Home greeting & Profile title so all three tab titles sit
            // the same distance from the top edge.
            .padding(.top, CGFloat.Spacing.lg)
            .padding(.bottom, CGFloat.Spacing.md)
    }

    private func sectionHeader(for tab: BookingTab) -> some View {
        Text(tab.sectionTitle)
            .font(.App.headline)
            .foregroundStyle(Color.App.text)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // The empty / loading states have nothing to scroll, so the header stays put.
    private func pinnedHeader(for tab: BookingTab) -> some View {
        sectionHeader(for: tab)
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.sm)
    }

    // MARK: - Paged content
    //
    // One page per tab, swipeable left/right; the selector above and the pager
    // are both bound to `tabSelection`, so tapping a tab and swiping stay in sync.
    private var pagedContent: some View {
        TabView(selection: tabSelection) {
            ForEach(BookingTab.allCases) { tab in
                tabContent(for: tab)
                    .tag(tab)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    @ViewBuilder
    private func tabContent(for tab: BookingTab) -> some View {
        switch viewModel.state(for: tab) {
        case .idle, .loading:
            VStack(alignment: .leading, spacing: 0) {
                pinnedHeader(for: tab)
                loadingState
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        case .loaded(let bookings):
            if bookings.isEmpty {
                refreshableState(for: tab) { emptyState(for: tab) }
            } else {
                list(bookings, tab: tab)
            }
        case .failed:
            refreshableState(for: tab) { emptyState(for: tab) }
        }
    }

    // The empty / failed states have nothing to scroll, so on their own they
    // can't be pulled. Wrap them in a ScrollView that always bounces (filling the
    // viewport height) so pull-to-refresh works even with no bookings.
    private func refreshableState<Content: View>(
        for tab: BookingTab,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                pinnedHeader(for: tab)
                content()
            }
            .frame(maxWidth: .infinity)
            .containerRelativeFrame(.vertical)
        }
        .scrollBounceBehavior(.always)
        .refreshable { await viewModel.refresh() }
    }

    private func list(_ bookings: [Booking], tab: BookingTab) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
                // Scrolls with the cards instead of being pinned above the list.
                sectionHeader(for: tab)
                    .padding(.top, CGFloat.Spacing.md)
                ForEach(bookings) { booking in
                    card(for: booking, tab: tab)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.lg)
            // Fade cards in / out as the list gains or loses bookings (silent
            // reload, pull-to-refresh) — keyed on the ids so unchanged refreshes
            // don't animate.
            .animation(.smooth, value: bookings.map(\.id))
        }
        .scrollBounceBehavior(.always)
        .refreshable { await viewModel.refresh() }
    }

    private func card(for booking: Booking, tab: BookingTab) -> some View {
        let isUpcoming = tab == .upcoming
        let model = BookingCardFormatter.make(booking, showMap: isUpcoming, relativeDay: isUpcoming)
        return AppointmentCardView(
            appointment: model,
            footerAction: isUpcoming ? .details : .book,
            showsDivider: false,
            onCardTap: { viewModel.didTapDetails(booking) },
            onFooterTap: {
                if isUpcoming {
                    viewModel.didTapDetails(booking)
                } else {
                    viewModel.didTapBook(booking)
                }
            }
        )
    }

    private var loadingState: some View {
        ProgressView()
            .tint(Color.App.brown1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func emptyState(for tab: BookingTab) -> some View {
        Text(tab.emptyMessage)
            .font(.App.body)
            .foregroundStyle(Color.App.gray)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, CGFloat.Spacing.lg)
    }
}
