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
                onSelect: viewModel.selectTab
            )
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.sm)

            Rectangle()
                .fill(Color.App.blueTransparency)
                .frame(height: 1)

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.App.backgroundLight)
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

    private var sectionHeader: some View {
        Text(viewModel.selectedTab.sectionTitle)
            .font(.App.headline)
            .foregroundStyle(Color.App.text)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // The empty / loading states have nothing to scroll, so the header stays put.
    private var pinnedHeader: some View {
        sectionHeader
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.sm)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.currentState {
        case .idle, .loading:
            VStack(alignment: .leading, spacing: 0) {
                pinnedHeader
                loadingState
            }
        case .loaded(let bookings):
            if bookings.isEmpty {
                refreshableState { emptyState }
            } else {
                list(bookings)
            }
        case .failed:
            refreshableState { emptyState }
        }
    }

    // The empty / failed states have nothing to scroll, so on their own they
    // can't be pulled. Wrap them in a ScrollView that always bounces (filling the
    // viewport height) so pull-to-refresh works even with no bookings.
    private func refreshableState<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                pinnedHeader
                content()
            }
            .frame(maxWidth: .infinity)
            .containerRelativeFrame(.vertical)
        }
        .scrollBounceBehavior(.always)
        .refreshable { await viewModel.refresh() }
    }

    private func list(_ bookings: [Booking]) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
                // Scrolls with the cards instead of being pinned above the list.
                sectionHeader
                    .padding(.top, CGFloat.Spacing.md)
                ForEach(bookings) { booking in
                    card(for: booking)
                }
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.lg)
        }
        .scrollBounceBehavior(.always)
        .refreshable { await viewModel.refresh() }
    }

    private func card(for booking: Booking) -> some View {
        let tab = viewModel.selectedTab
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

    private var emptyState: some View {
        Text(viewModel.selectedTab.emptyMessage)
            .font(.App.body)
            .foregroundStyle(Color.App.gray)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, CGFloat.Spacing.lg)
    }
}
