import Foundation
import Combine

// MARK: - SearchDatePickerViewModel

// Drives the "Оберіть дату" page (Figma 143:8732) pushed inside the search
// sheet: the shared booking calendar with Очистити/Застосувати actions.
// Nothing is committed until Застосувати — backing out keeps the previously
// applied date.

@MainActor
final class SearchDatePickerViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        let didTapBack: () -> Void
        /// Fires with the picked day, or `nil` after Очистити — applying a
        /// cleared selection removes the filter.
        let didApply: (Date?) -> Void
    }

    // MARK: - Published

    @Published var selectedDate: Date?

    // MARK: - Dependencies

    private let transition: Transition

    // MARK: - Init

    init(transition: Transition, initialDate: Date?) {
        self.transition = transition
        super.init()
        self.selectedDate = initialDate
    }

    // MARK: - Intents

    func didTapBack() {
        transition.didTapBack()
    }

    func didTapClear() {
        selectedDate = nil
    }

    func didTapApply() {
        transition.didApply(selectedDate)
    }
}
