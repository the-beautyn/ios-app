import Combine
import Foundation

// MARK: - ServiceTypeFilterViewModel
//
// State for the service-type filter sheet (Figma 143:8965): pick exactly one
// app category, Очистити deselects, Застосувати hands the pick (or nil to
// remove the filter) back to the map screen and closes the sheet.

@MainActor
final class ServiceTypeFilterViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        let didTapClose: () -> Void
    }

    // MARK: - Published State

    @Published private(set) var categories: [AppCategory] = []
    /// Kept as the full model (not just the id) so Застосувати can hand back
    /// the applied category even before the list finishes loading.
    @Published private(set) var selectedCategory: AppCategory?

    // MARK: - Dependencies

    private let transition: Transition
    private let onApply: (AppCategory?) -> Void
    private let getAppCategoriesUseCase: any GetAppCategoriesUseCase

    // MARK: - Init

    init(
        transition: Transition,
        context: ServiceTypeFilterContext,
        getAppCategoriesUseCase: any GetAppCategoriesUseCase
    ) {
        self.transition = transition
        self.onApply = context.onApply
        self.getAppCategoriesUseCase = getAppCategoriesUseCase
        self.selectedCategory = context.initialCategory
        super.init()
    }

    // MARK: - Lifecycle

    override func onViewTask() async {
        guard categories.isEmpty else { return }
        showLoader()
        defer { hideLoader() }
        do {
            categories = try await getAppCategoriesUseCase.execute()
        } catch {
            showError(error)
        }
    }

    // MARK: - Intents

    func didTapCategory(_ category: AppCategory) {
        // Radio behavior: picking a row moves the single selection there;
        // deselecting everything goes through Очистити.
        selectedCategory = category
    }

    func didTapClear() {
        selectedCategory = nil
    }

    func didTapApply() {
        onApply(selectedCategory)
        transition.didTapClose()
    }

    func didTapClose() {
        transition.didTapClose()
    }
}
