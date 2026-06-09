import Combine
import SwiftUI

// MARK: - HomeView

struct HomeView: BaseViewProtocol {

    @StateObject var viewModel: HomeViewModel

    var contentView: some View {
        VStack(spacing: 0) {
            headerSection
            scrollableContent
        }
    }

    // MARK: - Header (Pinned)

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
            // Greeting
            Text(viewModel.greeting)
                .font(.App.title2Medium)
                .tracking(CGFloat.Tracking.title2)
                .foregroundStyle(Color.App.text)
                .padding(.top, CGFloat.Spacing.lg)

            // Search bar
            SearchBarButton(onTap: viewModel.didTapSearch)

            // Categories
            if !viewModel.categories.isEmpty {
                categoriesRow
            }
        }
        .padding(.horizontal, CGFloat.Spacing.md)
        .padding(.bottom, CGFloat.Spacing.md)
        .background(Color.App.backgroundLight)
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [.black.opacity(0.1), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 12)
            .offset(y: 12)
        }
    }

    // MARK: - Categories Row

    private var categoriesRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: CGFloat.Spacing.sm) {
                ForEach(viewModel.categories) { category in
                    CategoryChipView(category: category) {
                        viewModel.didTapCategory(category)
                    }
                }
            }
            .padding(.horizontal, CGFloat.Spacing.md)
        }
        .padding(.horizontal, -CGFloat.Spacing.md)
    }

    // MARK: - Scrollable Content

    private var scrollableContent: some View {
        // GeometryReader + minHeight makes the content fill at least the viewport
        // so the scroll view always has a pull region — pull-to-refresh then works
        // even when the feed is empty. minHeight (not a fixed height) still lets a
        // tall feed grow and scroll normally.
        GeometryReader { proxy in
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: CGFloat.Spacing.lg + 4) {

                // Next Appointment (auth only)
                if let appointment = viewModel.nextAppointment {
                    VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
                        SectionHeaderView(title: Localization.homeSectionNextAppointment)
                        AppointmentCardView(
                            appointment: appointment,
                            onFooterTap: viewModel.didTapAppointmentDetails
                        )
                    }
                    .padding(.horizontal, CGFloat.Spacing.md)
                }

                // Saved Salons (auth only)
                if !viewModel.savedSalons.isEmpty {
                    VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
                        SectionHeaderView(
                            title: Localization.homeSectionSaved,
                            onSeeAll: viewModel.didTapSeeAllSaved
                        )
                        .padding(.horizontal, CGFloat.Spacing.md)
                        savedSalonsRow
                    }
                    // Fades the whole section when the first salon is saved / the
                    // last is removed, instead of popping the layout.
                    .transition(.opacity)
                }

                // Dynamic Sections
                ForEach(viewModel.sections) { section in
                    VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
                        SectionHeaderView(
                            title: section.title,
                            onSeeAll: { viewModel.didTapSeeAllSection(section.id) }
                        )
                        .padding(.horizontal, CGFloat.Spacing.md)
                        salonCardsRow(items: section.items)
                    }
                }
            }
            .padding(.top, CGFloat.Spacing.lg)
            .padding(.bottom, CGFloat.Spacing.xxxl)
            .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .topLeading)
        }
        .refreshable {
            await viewModel.refresh()
        }
        // With the content filling the viewport, force the bounce so the pull
        // gesture is available even when the feed is empty / exactly fits.
        .scrollBounceBehavior(.always)
        }
    }

    // MARK: - Saved Salons Row

    private var savedSalonsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: CGFloat.Spacing.sm) {
                ForEach(viewModel.savedSalons) { salon in
                    SavedSalonItemView(salon: salon) {
                        viewModel.didTapSavedSalon(salon)
                    }
                    // Items scale/fade in/out while the rest of the row slides
                    // to make room (driven by the view model's withAnimation).
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, CGFloat.Spacing.md)
        }
    }

    // MARK: - Salon Cards Row

    private func salonCardsRow(items: [SalonCardModel]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CGFloat.Spacing.sm) {
                ForEach(items) { salon in
                    SalonCardView(
                        salon: salon,
                        style: .horizontal,
                        onTap: { viewModel.didTapSalonCard(salon.id) },
                        onFavoriteTap: { viewModel.didTapFavorite(salonId: salon.id) }
                    )
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, CGFloat.Spacing.md)
        }
        .scrollTargetBehavior(.viewAligned)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    HomeView(
        viewModel: HomeViewModel(
            transition: .init(
                didTapSearch: {},
                didTapSalonCard: { _ in },
                didTapSavedSalon: { _ in },
                didTapSeeAllSaved: {},
                didTapSeeAllSection: { _ in },
                didTapAppointmentDetails: { _ in },
                didTapCategory: { _ in },
                didRequireAuth: {}
            ),
            getHomeFeedUseCase: PreviewGetHomeFeedUseCase(),
            saveSalonUseCase: PreviewSaveSalonUseCase(),
            unsaveSalonUseCase: PreviewUnsaveSalonUseCase(),
            savedSalonsEventBus: PreviewSavedSalonsEventBus(),
            bookingEventBus: BookingEventBusImpl(),
            sessionManager: SessionManager(keychainService: KeychainServiceImpl(), defaultsService: DefaultsStorageService()),
            getCurrentUserUseCase: PreviewGetCurrentUserUseCase()
        )
    )
}

private final class PreviewGetHomeFeedUseCase: GetHomeFeedUseCase {
    func execute(latitude: Double?, longitude: Double?) async throws -> HomeFeed {
        HomeFeed(categories: [], nextBooking: nil, savedSalons: nil, sections: [])
    }
}

private final class PreviewSaveSalonUseCase: SaveSalonUseCase {
    func execute(salonId: String) async throws {}
}

private final class PreviewUnsaveSalonUseCase: UnsaveSalonUseCase {
    func execute(salonId: String) async throws {}
}

private final class PreviewSavedSalonsEventBus: SavedSalonsEventBus {
    var changes: AnyPublisher<SavedSalonChange, Never> { Empty().eraseToAnyPublisher() }
    func notify(_ change: SavedSalonChange) {}
}

private final class PreviewGetCurrentUserUseCase: GetCurrentUserUseCase {
    func execute() async throws -> UserProfile {
        throw URLError(.userAuthenticationRequired)
    }
}
#endif
