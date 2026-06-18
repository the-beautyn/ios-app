import SwiftUI
import UIKit

// MARK: - SelectServiceView

struct SelectServiceView: BaseViewProtocol {

    @StateObject var viewModel: SelectServiceViewModel

    var contentView: some View {
        VStack(spacing: CGFloat.Spacing.md) {
            if viewModel.categoryTabs.isEmpty {
                emptyState
            } else {
                TabSelectorView(
                    tabs: viewModel.categoryTitles,
                    selectedIndex: $viewModel.selectedCategoryIndex
                )
                .padding(.horizontal, CGFloat.Spacing.md)

                pagedCategoryContent
            }
        }
        .padding(.top, CGFloat.Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.App.white)
        // Dismiss the search keyboard when the user changes category (tap or
        // swipe) — but only after the page-slide + tab-scroll animations settle,
        // since dismissing mid-animation cancels them.
        .onChange(of: viewModel.selectedCategoryIndex) { _, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                UIApplication.shared.endEditing()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SelectServiceBottomBar(
                totalDurationText: viewModel.totalDurationText,
                totalPriceText: viewModel.totalPriceText,
                canEdit: viewModel.hasSelection && !viewModel.isToggling,
                canContinue: viewModel.hasSelection && !viewModel.isToggling,
                onEdit: viewModel.didTapEditServices,
                onContinue: viewModel.didTapContinue
            )
        }
        // The search field sits high under the tab selector, clear of the
        // keyboard — opt out of keyboard avoidance so the list and bottom bar
        // don't shift when the keyboard appears.
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $viewModel.isEditingServices) {
            EditServicesSheet(
                countText: viewModel.selectedCountText,
                totalDurationText: viewModel.totalDurationText,
                totalPriceText: viewModel.editSheetTotalPriceText,
                services: viewModel.addedServiceRows,
                onRemove: { viewModel.removeService(id: $0) },
                onClose: { viewModel.isEditingServices = false }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(32)
        }
    }

    // MARK: - Paged category content
    //
    // One independent list per category, swipeable left/right. Each carries its
    // own search field (inside SalonListTab) so queries stay scoped per category.
    // The pager and the TabSelectorView above are both bound to
    // `selectedCategoryIndex`, so tapping a tab and swiping stay in sync.
    private var pagedCategoryContent: some View {
        TabView(selection: $viewModel.selectedCategoryIndex) {
            ForEach(Array(viewModel.categoryTabs.enumerated()), id: \.element.id) { index, tab in
                SalonListTab(
                    placeholder: Localization.salonProfileSearchPlaceholder,
                    searchText: viewModel.searchBinding(for: tab),
                    isEmpty: viewModel.filteredServices(for: tab).isEmpty,
                    emptyMessage: Localization.salonProfileNothingFound
                ) {
                    ForEach(viewModel.filteredServices(for: tab)) { service in
                        SelectServiceRow(
                            service: viewModel.serviceRowModel(for: service),
                            isLoading: viewModel.pendingServiceId == service.id,
                            onToggle: { viewModel.toggle(service) }
                        )
                        // While one toggle resolves, block the other rows so the
                        // selection can't change under a stale availability list.
                        .disabled(viewModel.isToggling && viewModel.pendingServiceId != service.id)
                        // 12pt gap between cards (SalonListTab's LazyVStack is spacing: 0).
                        .padding(.bottom, CGFloat.Spacing.sm + CGFloat.Spacing.xs)
                        // Fade the row (and its spacing) in/out when the
                        // availability list reloads after a refetch.
                        .transition(.opacity)
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    private var emptyState: some View {
        Text(Localization.salonProfileNothingFound)
            .font(.App.subheadline)
            .foregroundStyle(Color.App.gray2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

// MARK: - Preview

#if DEBUG

private extension Salon {

    static func previewAltegio(
        services: [SalonService],
        categories: [SalonCategory]
    ) -> Salon {
        Salon(
            id: "s1",
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
            workingSchedule: nil,
            topMastersTag: nil,
            isSaved: false,
            services: services,
            workers: [
                SalonWorker(id: "w1", firstName: "Ashley", lastName: "Brown", position: "Майстер манікюру", description: nil, photoUrl: nil)
            ],
            categories: categories
        )
    }

    static let previewCategories: [SalonCategory] = [
        SalonCategory(id: "c1", salonId: "s1", name: "Манікюр", color: nil, sortOrder: 0, serviceIds: []),
        SalonCategory(id: "c2", salonId: "s1", name: "Педікюр", color: nil, sortOrder: 1, serviceIds: []),
        SalonCategory(id: "c3", salonId: "s1", name: "One Time", color: nil, sortOrder: 2, serviceIds: []),
        SalonCategory(id: "c4", salonId: "s1", name: "Догляд", color: nil, sortOrder: 3, serviceIds: [])
    ]

    static let previewServices: [SalonService] = [
        SalonService(id: "srv1", salonId: "s1", categoryId: "c1", name: "Classic Manicure", description: "Охайна форма, кутикула, легкий саге та базове покриття.", durationMinutes: 90, price: 700, currency: "UAH", isActive: true, sortOrder: 0, workerIds: [], imageUrls: []),
        SalonService(id: "srv2", salonId: "s1", categoryId: "c1", name: "French Manicure", description: "Класичний французький манікюр із гель-лаком.", durationMinutes: 120, price: 900, currency: "UAH", isActive: true, sortOrder: 1, workerIds: [], imageUrls: []),
        SalonService(id: "srv3", salonId: "s1", categoryId: "c1", name: "Nail Art", description: "Художній розпис нігтів.", durationMinutes: 60, price: 500, currency: "UAH", isActive: true, sortOrder: 2, workerIds: [], imageUrls: []),
        SalonService(id: "srv4", salonId: "s1", categoryId: "c2", name: "Pedicure Express", description: "Швидкий педикюр із покриттям.", durationMinutes: 60, price: 600, currency: "UAH", isActive: true, sortOrder: 0, workerIds: [], imageUrls: [])
    ]
}

private final class PreviewGetAltegioAvailableServicesUseCase: GetAltegioAvailableServicesUseCase {
    let ids: Set<String>
    init(ids: Set<String>) { self.ids = ids }
    func execute(salonId: String, selectedServiceIds: [String], workerId: String?, datetime: String?) async throws -> Set<String> { ids }
}

@MainActor
private func makePreviewVM(entry: SalonBookingEntry) -> SelectServiceViewModel {
    let services = Salon.previewServices
    let ids = Set(services.map { $0.id })
    return SelectServiceViewModel(
        salon: .previewAltegio(services: services, categories: Salon.previewCategories),
        entry: entry,
        initialAvailableServiceIds: ids,
        transition: .init(didContinue: { _, _, _, _ in }),
        getAltegioAvailableServicesUseCase: PreviewGetAltegioAvailableServicesUseCase(ids: ids)
    )
}

#Preview("Empty (Book)") {
    NavigationStack {
        SelectServiceView(viewModel: makePreviewVM(entry: .book))
            .navigationTitle(Localization.selectServiceTitle)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Preselected service") {
    NavigationStack {
        SelectServiceView(viewModel: makePreviewVM(entry: .service(id: "srv1")))
            .navigationTitle(Localization.selectServiceTitle)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#endif
