import Combine
import Foundation
import SwiftUI

// MARK: - SearchSortViewModel
//
// Drives the sort & price filter sheet (Figma 143:8873): a radio list of
// sort options and a max-price slider. The bounds come pre-fetched through
// the context (the map screen loads them once on init), so the sheet is
// fully synchronous.

@MainActor
final class SearchSortViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        /// Dismisses the (transparent) container — fired only after the
        /// sheet's slide-out finishes. Applying goes through the context's
        /// `onApply` instead, immediately on Застосувати, so the map starts
        /// refreshing behind the sheet while it slides away.
        let didTapClose: () -> Void
    }

    // MARK: - Constants

    /// Track bounds when the backend has no price data (or the one-time
    /// fetch failed) — the upper matches the Figma mock's "3000 грн".
    static let fallbackLowerBound: Double = 0
    static let fallbackUpperBound: Double = 3_000
    static let priceStep: Double = 100

    /// The sheet's rows in Figma order — `priceDesc` isn't surfaced (the
    /// design has a single "За ціною", mapped to cheapest-first).
    private static let designOrderedSorts: [SearchSortOption] = [.ratingDesc, .popular, .distance, .priceAsc]

    // MARK: - Published

    /// Drives the AppBottomSheet overlay: flipped on after the transparent
    /// container appears (slide-in) and off to slide out; every route out of
    /// the screen goes through the `didSet` so the container is dismissed
    /// only after the slide-out animation finishes.
    @Published var isSheetPresented = false {
        didSet {
            guard oldValue, !isSheetPresented else { return }
            finishDismissAfterSlideOut()
        }
    }
    @Published var selectedSort: SearchSortOption?
    @Published var priceLowerValue: Double
    @Published var priceUpperValue: Double

    /// The design-ordered rows, narrowed to what the server still accepts.
    let sortOptions: [SearchSortOption]
    /// Global price track (cheapest…priciest service anywhere, snapped to the
    /// step). A knob resting on its own edge = that side of the filter is off.
    let priceLowerBound: Double
    let priceUpperBound: Double

    // MARK: - Dependencies

    private let transition: Transition
    private let onApply: (SearchSortSubmission) -> Void
    private var hasStartedInitialLoad = false
    private var isDismissScheduled = false

    /// Matches the AppBottomSheet spring (response 0.38).
    private static let slideOutDuration: Duration = .milliseconds(400)

    // MARK: - Init

    init(transition: Transition, context: SearchSortContext) {
        self.transition = transition
        self.onApply = context.onApply
        self.selectedSort = context.initialSort

        let bounds = Self.trackBounds(from: context.filterOptions)
        self.priceLowerBound = bounds.lowerBound
        self.priceUpperBound = bounds.upperBound
        // The applied range may fall outside the current global track — clamp
        // it in, keeping at least one step of separation so the slider never
        // opens with collapsed knobs.
        let upper = min(context.initialPriceMax ?? bounds.upperBound, bounds.upperBound)
        let lower = min(max(context.initialPriceMin ?? bounds.lowerBound, bounds.lowerBound), upper)
        self.priceUpperValue = upper
        self.priceLowerValue = min(lower, max(bounds.lowerBound, upper - Self.priceStep))

        if let serverOptions = context.filterOptions?.sortOptions, !serverOptions.isEmpty {
            self.sortOptions = Self.designOrderedSorts.filter(Set(serverOptions).contains)
        } else {
            self.sortOptions = Self.designOrderedSorts
        }
        super.init()
    }

    // MARK: - Lifecycle

    override func onViewTask() async {
        guard !hasStartedInitialLoad else { return }
        hasStartedInitialLoad = true
        // The container is up (transparent) — slide the sheet in.
        isSheetPresented = true
    }

    // MARK: - Intents

    func didSelectSort(_ option: SearchSortOption) {
        selectedSort = option
    }

    /// Resets the controls in place — nothing is applied until Застосувати.
    /// No sort selected = the request omits `sortBy`, restoring the backend's
    /// contextual default (distance with a center, rating otherwise).
    func didTapClear() {
        selectedSort = nil
        priceLowerValue = priceLowerBound
        priceUpperValue = priceUpperBound
    }

    func didTapApply() {
        // Apply right away — the map refreshes behind the sliding-out sheet.
        onApply(SearchSortSubmission(
            sort: selectedSort,
            priceMin: priceLowerValue <= priceLowerBound ? nil : priceLowerValue,
            priceMax: priceUpperValue >= priceUpperBound ? nil : priceUpperValue
        ))
        isSheetPresented = false
    }

    func didTapClose() {
        isSheetPresented = false
    }

    // MARK: - Private

    /// Snaps the global bounds to the step (start down, end up) so the knobs'
    /// step grid always includes both edges; falls back on missing or
    /// degenerate data.
    private static func trackBounds(from options: SearchFilterOptions?) -> ClosedRange<Double> {
        guard let maxPrice = options?.maxPrice, maxPrice > 0 else {
            return fallbackLowerBound...fallbackUpperBound
        }
        let upper = (maxPrice / priceStep).rounded(.up) * priceStep
        let lower = ((options?.minPrice ?? 0) / priceStep).rounded(.down) * priceStep
        guard lower >= 0, upper > lower else { return fallbackLowerBound...fallbackUpperBound }
        return lower...upper
    }

    /// Waits out the sheet's slide-out, then has the coordinator drop the
    /// transparent container — same route for Застосувати, ✕ and dim tap.
    private func finishDismissAfterSlideOut() {
        guard !isDismissScheduled else { return }
        isDismissScheduled = true
        Task { [weak self] in
            try? await Task.sleep(for: Self.slideOutDuration)
            self?.transition.didTapClose()
        }
    }
}
