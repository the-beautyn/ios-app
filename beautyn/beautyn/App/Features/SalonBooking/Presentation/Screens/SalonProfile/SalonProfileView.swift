import Combine
import SwiftUI
import UIKit

// MARK: - SalonProfileView

struct SalonProfileView: BaseViewProtocol {

    @StateObject var viewModel: SalonProfileViewModel
    @FocusState private var searchFocused: Bool

    // Cover/sheet layout constants. Three layers stack on screen:
    //   • Cover photo — full-bleed from y=0 (under status bar) to y=coverHeight
    //   • Sheet — its rounded top sits at y=sheetTop, overlapping the bottom
    //     `overlap` pt of the cover
    //   • Header glass buttons — pinned BELOW the status bar (respect safe area)
    // Using a fixed sheetTop keeps the layout predictable across devices
    // without depending on GeometryReader + ignoresSafeArea interactions.
    private static let sheetTop: CGFloat = 290     // y position of sheet's top, from screen top
    private static let overlap: CGFloat = 100      // sheet curls this far over cover
    private static var coverHeight: CGFloat { sheetTop + overlap }

    var contentView: some View {
        ZStack(alignment: .top) {
            SalonCoverCarouselView(
                imageUrls: coverImageUrls,
                height: Self.coverHeight,
                // Sheet curls over the bottom `overlap` of the cover — reserve
                // that strip plus a small breathing room so the page-indicator
                // dots sit just above the sheet's rounded top corners.
                indicatorBottomInset: Self.overlap + CGFloat.Spacing.lg
            )
            .frame(maxWidth: .infinity)

            sheetContent
                .background(
                    UnevenRoundedRectangle(
                        cornerRadii: .init(topLeading: 32, topTrailing: 32),
                        style: .continuous
                    )
                    .fill(Color.App.white)
                )
                .padding(.top, Self.sheetTop)
        }
        .ignoresSafeArea(edges: .top)
        .background(Color.App.beige2.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SalonStickyActionBar(
                optionsCount: viewModel.optionsCount,
                ctaTitle: Localization.salonBookButton,
                onBook: viewModel.didTapBook
            )
        }
        .sheet(item: $viewModel.shareSheet) { presentation in
            ShareSheetRepresentable(items: [presentation.url, presentation.title])
        }
        .onChange(of: viewModel.selectedTab) { _, _ in
            // Switching tabs swaps which list the search filters against, so
            // any in-progress query becomes meaningless — clear it and drop
            // keyboard focus so the user sees the freshly switched tab's
            // full list without lingering filter state.
            viewModel.searchQuery = ""
            searchFocused = false
        }
    }

    private var coverImageUrls: [URL] {
        guard let salon = viewModel.salon else { return [] }
        // Lead with the cover, then the gallery — deduped so a cover that also
        // appears in the gallery isn't shown twice. Order is otherwise preserved.
        var seen = Set<String>()
        return ([salon.coverImageUrl].compactMap { $0 } + salon.imageUrls)
            .filter { seen.insert($0).inserted }
            .compactMap(URL.init(string:))
    }

    // MARK: - Sheet Content

    private var sheetContent: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.md) {
            if let salon = viewModel.salon {
                SalonProfileHeaderSection(
                    tag: salon.topMastersTag,
                    name: salon.name,
                    rating: salon.ratingAvg,
                    address: salon.addressLine,
                    workingSchedule: salon.workingSchedule
                )
                .padding(.horizontal, CGFloat.Spacing.md)

                TabSelectorView(
                    tabs: [
                        Localization.salonTabServices,
                        Localization.salonTabSpecialists
                    ],
                    selectedIndex: $viewModel.selectedTab
                )
                .padding(.horizontal, CGFloat.Spacing.md)

                SalonSearchField(
                    placeholder: Localization.salonProfileSearchPlaceholder,
                    text: $viewModel.searchQuery,
                    isFocused: $searchFocused
                )
                .padding(.horizontal, CGFloat.Spacing.md)

                scrollableListContent
            }
        }
        .padding(.top, CGFloat.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Scrollable List

    @ViewBuilder
    private var scrollableListContent: some View {
        if currentListIsEmpty {
            emptyResultsLabel
        } else {
            ScrollView(showsIndicators: false) {
                listContent
                    .padding(.horizontal, CGFloat.Spacing.md)
                    .padding(.bottom, CGFloat.Spacing.md)
            }
        }
    }

    private var currentListIsEmpty: Bool {
        viewModel.selectedTab == 0
            ? viewModel.filteredServices.isEmpty
            : viewModel.filteredWorkers.isEmpty
    }

    @ViewBuilder
    private var listContent: some View {
        if viewModel.selectedTab == 0 {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.filteredServices) { service in
                    ServiceRowView(
                        service: viewModel.serviceRowModel(for: service),
                        showsActionButton: viewModel.showsRowActions,
                        onAdd: { }
                    )
                }
            }
        } else {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.filteredWorkers) { worker in
                    SpecialistRowView(
                        specialist: viewModel.specialistRowModel(for: worker),
                        selectedTimeSlot: .constant(nil),
                        showsActionButton: viewModel.showsRowActions,
                        onSelect: { }
                    )
                }
            }
        }
    }

    private var emptyResultsLabel: some View {
        Text(Localization.salonProfileNothingFound)
            .font(.App.subheadline)
            .foregroundStyle(Color.App.gray2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

}

// MARK: - ShareSheetRepresentable

private struct ShareSheetRepresentable: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

// MARK: - Preview

#if DEBUG

private final class PreviewGetSalonByIdUseCase: GetSalonByIdUseCase {
    let salon: Salon
    init(salon: Salon) { self.salon = salon }
    func execute(id: String) async throws -> Salon { salon }
}

private final class PreviewGetSalonShareUseCase: GetSalonShareUseCase {
    func execute(id: String) async throws -> SalonShare {
        SalonShare(
            url: URL(string: "https://stage.beautyn.com.ua/salon/\(id)")!,
            title: "Nail bar: Glossy Room",
            description: nil
        )
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

private extension Salon {

    static let previewWithTag = Salon(
        id: "s1",
        name: "Nail bar: Glossy Room",
        provider: .easyweek,
        bookingUrl: URL(string: "https://booking.easyweek.com.ua/glossy-room"),
        addressLine: "вул. Зеленицька, 15, 05-091",
        city: "Київ",
        phone: nil,
        description: nil,
        coverImageUrl: "https://picsum.photos/seed/salon1/800/600",
        imageUrls: [
            "https://picsum.photos/seed/salon1/800/600",
            "https://picsum.photos/seed/salon2/800/600",
            "https://picsum.photos/seed/salon3/800/600"
        ],
        ratingAvg: 4.5,
        ratingCount: 120,
        workingSchedule: "ПН – ВС, 12:00 — 20:00",
        topMastersTag: "Top 10 Masters",
        isSaved: false,
        services: previewServices,
        workers: previewWorkers,
        categories: []
    )

    static let previewWithoutTag = Salon(
        id: "s2",
        name: "Beauty Studio Kyiv",
        provider: .altegio,
        bookingUrl: nil,
        addressLine: "вул. Франка, 10",
        city: "Київ",
        phone: nil,
        description: nil,
        coverImageUrl: nil,
        imageUrls: [],
        ratingAvg: 4.8,
        ratingCount: 85,
        workingSchedule: "ПН – ПТ, 10:00 — 21:00",
        topMastersTag: nil,
        isSaved: true,
        services: [],
        workers: [],
        categories: []
    )

    private static let previewServices: [SalonService] = [
        SalonService(
            id: "srv1", salonId: "s1", categoryId: nil,
            name: "Classic Manicure",
            description: "Охайна форма, кутикула, легкий care та базове покриття.",
            durationMinutes: 90, price: 700, currency: "UAH",
            isActive: true, sortOrder: 0, workerIds: [], imageUrls: []
        ),
        SalonService(
            id: "srv2", salonId: "s1", categoryId: nil,
            name: "French Manicure",
            description: "Класичний французький манікюр із гель-лаком.",
            durationMinutes: 120, price: 900, currency: "UAH",
            isActive: true, sortOrder: 1, workerIds: [], imageUrls: []
        ),
        SalonService(
            id: "srv3", salonId: "s1", categoryId: nil,
            name: "Pedicure Express",
            description: "Швидкий педикюр із покриттям.",
            durationMinutes: 60, price: 600, currency: "UAH",
            isActive: true, sortOrder: 2, workerIds: [], imageUrls: []
        )
    ]

    private static let previewWorkers: [SalonWorker] = [
        SalonWorker(id: "w1", firstName: "Ashley", lastName: "Brown", position: "Майстер манікюру", description: nil, photoUrl: nil),
        SalonWorker(id: "w2", firstName: "Amber", lastName: "Stone", position: "Майстер манікюру", description: nil, photoUrl: nil),
        SalonWorker(id: "w3", firstName: "Олена", lastName: "Коваль", position: "Топ-майстер", description: nil, photoUrl: nil)
    ]
}

@MainActor
private func makePreviewViewModel(salon: Salon) -> SalonProfileViewModel {
    SalonProfileViewModel(
        salonId: salon.id,
        transition: .init(
            didTapBack: {},
            didRequireAuth: {},
            didRequestBooking: { _ in }
        ),
        getSalonByIdUseCase: PreviewGetSalonByIdUseCase(salon: salon),
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

#Preview("With tag + content") {
    SalonProfileView(viewModel: makePreviewViewModel(salon: .previewWithTag))
}

#Preview("No tag + empty lists") {
    SalonProfileView(viewModel: makePreviewViewModel(salon: .previewWithoutTag))
}

#endif
