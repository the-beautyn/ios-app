import Combine
import SwiftUI

// MARK: - BookingDetailsView
//
// Booking Details screen (Figma 143:3861 future / 143:5143 cancelled /
// 143:5082 past). A pinned full-bleed salon cover with the salon name, and a
// rounded white sheet that overlaps the cover's bottom and fills to the screen
// edge. The cover stays put — only the sheet's content scrolls — so long
// service lists stay reachable. The glass back / share / favorite controls are
// nav-bar items installed by `BookingDetailsController`.

struct BookingDetailsView: BaseViewProtocol {

    @StateObject var viewModel: BookingDetailsViewModel

    // Cover photo height; the sheet's rounded top sits `sheetOverlap` above the
    // cover's bottom (Figma: cover 385, sheet top 348).
    private static let coverHeight: CGFloat = 385
    private static let sheetOverlap: CGFloat = 37
    private static var sheetTop: CGFloat { coverHeight - sheetOverlap }

    var contentView: some View {
        ZStack(alignment: .top) {
            cover

            scrollableSheet
                .padding(.top, Self.sheetTop)
        }
        // Ignore the top safe area (cover bleeds under the status bar) and the
        // bottom (the sheet's scroll content fills to the screen edge, matching
        // the white background — see `scrollableSheet`; the content's 48pt bottom
        // padding keeps the last row clear of the home indicator).
        .ignoresSafeArea(edges: [.top, .bottom])
        .background(Color.App.beige2.ignoresSafeArea())
        .sheet(item: $viewModel.shareSheet) { presentation in
            ShareSheetRepresentable(items: [presentation.url, presentation.title])
        }
        .sheet(item: $viewModel.calendarDraft) { draft in
            EventEditViewRepresentable(eventStore: draft.store, event: draft.event) {
                viewModel.calendarDraft = nil
            }
        }
        .confirmationDialog(
            Localization.mapsChooserTitle,
            isPresented: $viewModel.isShowingMapsChooser,
            titleVisibility: .visible
        ) {
            Button(Localization.mapsAppleMaps) { viewModel.openAppleMaps() }
            Button(Localization.mapsGoogleMaps) { viewModel.openGoogleMaps() }
        }
    }

    // MARK: - Cover

    private var cover: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                CachedImage(
                    url: viewModel.salonImageURL,
                    size: CGSize(width: geo.size.width, height: Self.coverHeight),
                    clipShape: Rectangle()
                )
                .overlay(Color.App.brown1.opacity(0.2))
                .overlay(
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                Text(viewModel.salonName)
                    .font(.App.largeTitleBold)
                    .foregroundStyle(Color.App.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, CGFloat.Spacing.md)
                    .padding(.bottom, Self.sheetOverlap + CGFloat.Spacing.lg)
            }
            .frame(width: geo.size.width, height: Self.coverHeight)
        }
        .frame(height: Self.coverHeight)
    }

    // MARK: - Sheet

    // Fixed white panel (pinned top + filling to the bottom) whose content
    // scrolls — the cover behind it stays put.
    private var scrollableSheet: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
                BookingStatusBadge(style: badgeStyle, text: viewModel.statusText)

                dateTimeBlock
                actionRows

                Text(Localization.bookingDetailsServicesSection)
                    .font(.App.headline)
                    .foregroundStyle(Color.App.text)

                servicesBlock
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.xl)
            .padding(.bottom, CGFloat.Spacing.xxl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        // Clip the content to the sheet shape so anything at the top (e.g. the
        // status badge) is cut by the sheet's rounded edge, never spilling onto
        // the cover image above it.
        .clipShape(Self.sheetShape)
        .background(
            Self.sheetShape
                .fill(Color.App.white)
                .ignoresSafeArea(edges: .bottom)   // white fills under the home indicator
        )
    }

    private static let sheetShape = UnevenRoundedRectangle(
        cornerRadii: .init(topLeading: 32, topTrailing: 32),
        style: .continuous
    )

    private var badgeStyle: BookingStatusBadge.Style {
        switch viewModel.state {
        case .future: return .confirmed
        case .past: return .completed
        case .cancelled: return .cancelled
        }
    }

    private var dateTimeBlock: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.xs) {
            Text(viewModel.dateTimeText)
                .font(.App.title1Medium)
                .tracking(CGFloat.Tracking.title1)
                .foregroundStyle(Color.App.text)
                .fixedSize(horizontal: false, vertical: true)

            if !viewModel.durationText.isEmpty {
                Text(viewModel.durationText)
                    .font(.App.caption2)
                    .tracking(CGFloat.Tracking.caption2)
                    .foregroundStyle(Color.App.gray)
            }
        }
    }

    // MARK: - Action rows

    @ViewBuilder
    private var actionRows: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
            if viewModel.showsCalendarAction {
                BookingActionRow(
                    icon: "calendar",
                    title: Localization.bookingDetailsAddToCalendar,
                    action: viewModel.didTapAddToCalendar
                )
            }
            if viewModel.showsRouteAction {
                BookingActionRow(
                    icon: "map",
                    title: Localization.bookingDetailsRoute,
                    subtitle: viewModel.routeSubtitle,
                    action: viewModel.didTapRoute
                )
            }
            if viewModel.showsMakeChangesAction {
                BookingActionRow(
                    icon: "calendar.badge.clock",
                    title: Localization.bookingDetailsMakeChanges,
                    subtitle: Localization.bookingDetailsMakeChangesSubtitle,
                    action: viewModel.didTapMakeChanges
                )
            }
            if viewModel.showsBookAgainAction {
                BookingActionRow(
                    icon: "calendar.badge.plus",
                    title: Localization.bookingDetailsBookAgain,
                    action: viewModel.didTapBookAgain
                )
            }
        }
        .padding(.vertical, CGFloat.Spacing.sm)
    }

    // MARK: - Services

    private var servicesBlock: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
            ForEach(Array(viewModel.serviceRows.enumerated()), id: \.offset) { _, row in
                serviceRow(row)
            }

            Rectangle()
                .fill(Color.App.blueTransparency)
                .frame(height: 1)

            totalRow
        }
    }

    private func serviceRow(_ row: BookingDetailsViewModel.ServiceRow) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                Text(row.name)
                    .font(.App.footnote)
                    .foregroundStyle(Color.App.black)

                if let description = row.description, !description.isEmpty {
                    Text(description)
                        .font(.App.caption2)
                        .tracking(CGFloat.Tracking.caption2)
                        .foregroundStyle(Color.App.gray2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: CGFloat.Spacing.sm)

            if let price = row.price {
                Text(price)
                    .font(.App.footnote)
                    .foregroundStyle(Color.App.black)
            }
        }
        .padding(.vertical, CGFloat.Spacing.xs)
    }

    private var totalRow: some View {
        HStack {
            Text(Localization.bookingDetailsTotal)
                .font(.App.footnoteSemibold)
                .foregroundStyle(Color.App.black)

            Spacer()

            Text(viewModel.totalText)
                .font(.App.footnoteSemibold)
                .foregroundStyle(Color.App.black)
        }
        .padding(.vertical, CGFloat.Spacing.xs)
    }
}

// MARK: - Preview

#if DEBUG

private final class PreviewObserveBookingUseCase: ObserveBookingUseCase {
    func execute(id: String) -> AnyPublisher<Booking?, Never> {
        Just(nil).eraseToAnyPublisher()
    }
}

private final class PreviewGetSalonByIdUseCase: GetSalonByIdUseCase {
    func execute(id: String, isFromSearch: Bool) async throws -> Salon {
        throw CancellationError()   // favorite state stays default in previews
    }
}

private final class PreviewGetSalonShareUseCase: GetSalonShareUseCase {
    func execute(id: String) async throws -> SalonShare {
        SalonShare(url: URL(string: "https://stage.beautyn.com.ua/salon/\(id)")!, title: "Nail bar: Glossy Room", description: nil)
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

@MainActor
private final class PreviewRefreshBookingUseCase: RefreshBookingUseCase {
    func execute(id: String) async throws -> Booking { .preview(status: .created) }
}

@MainActor
private final class PreviewSyncBookingFromCrmUseCase: SyncBookingFromCrmUseCase {
    func execute(id: String) async throws -> Booking { .preview(status: .created) }
}

private final class PreviewConfirmEasyweekBookingUseCase: ConfirmEasyweekBookingUseCase {
    func execute(salonId: String, bookingUuid: String) async throws -> Booking {
        .preview(status: .created)
    }
}

private final class PreviewGetCurrentUserUseCase: GetCurrentUserUseCase {
    func execute() async throws -> UserProfile {
        UserProfile(
            id: "u1", email: "user@example.com", role: "client", name: "Ольга",
            secondName: nil, phone: "+380506314634", avatarUrl: nil, birthDate: nil, city: nil,
            sex: nil, authProvider: "email", isPhoneVerified: true, isProfileCreated: true
        )
    }
}

private extension Booking {
    static func preview(status: BookingStatus, bookingUrl: URL? = URL(string: "https://beautyn.com.ua/b/abc123")) -> Booking {
        Booking(
            id: "b1",
            salonId: "s1",
            salonName: "Nail bar: Glossy Room",
            salonAddress: "вул. Зеленицька, 15 (411), 05-091",
            salonImageURL: URL(string: "https://picsum.photos/seed/salon1/800/600"),
            coordinate: nil,
            bookingUrl: bookingUrl,
            crmType: .altegio,
            crmRecordId: nil,
            status: status,
            datetime: Date().addingTimeInterval(86_400),
            endDatetime: Date().addingTimeInterval(86_400 + 5_400),
            cancelledAt: nil,
            services: [
                BookingService(id: "srv1", name: "Classic Manicure", description: "Охайна форма, кутикула, легкий care та базове покриття.", price: 700)
            ],
            totalPrice: 700,
            currency: "UAH",
            durationMinutes: 90,
            timezone: TimeZone(identifier: "Europe/Kyiv")
        )
    }
}

@MainActor
private func makePreviewViewModel(status: BookingStatus) -> BookingDetailsViewModel {
    BookingDetailsViewModel(
        booking: .preview(status: status),
        transition: .init(didTapBookAgain: { _ in }, didRequireAuth: {}, didOpenBookingDetails: { _ in }),
        observeBookingUseCase: PreviewObserveBookingUseCase(),
        refreshBookingUseCase: PreviewRefreshBookingUseCase(),
        syncBookingFromCrmUseCase: PreviewSyncBookingFromCrmUseCase(),
        confirmEasyweekBookingUseCase: PreviewConfirmEasyweekBookingUseCase(),
        getCurrentUserUseCase: PreviewGetCurrentUserUseCase(),
        getSalonByIdUseCase: PreviewGetSalonByIdUseCase(),
        getSalonShareUseCase: PreviewGetSalonShareUseCase(),
        saveSalonUseCase: PreviewSaveSalonUseCase(),
        unsaveSalonUseCase: PreviewUnsaveSalonUseCase(),
        savedSalonsEventBus: PreviewSavedSalonsEventBus(),
        sessionManager: SessionManager(
            keychainService: KeychainServiceImpl(),
            defaultsService: DefaultsStorageService()
        )
    )
}

#Preview("Future") {
    BookingDetailsView(viewModel: makePreviewViewModel(status: .created))
}

#Preview("Past") {
    BookingDetailsView(viewModel: makePreviewViewModel(status: .completed))
}

#Preview("Cancelled") {
    BookingDetailsView(viewModel: makePreviewViewModel(status: .canceled))
}

#endif
