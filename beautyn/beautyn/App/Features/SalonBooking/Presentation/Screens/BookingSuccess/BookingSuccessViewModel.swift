import Foundation

// MARK: - BookingSuccessViewModel
//
// Transient confirmation splash shown right after an Altegio booking is created
// (Figma 143:3199). It only displays the brand logo + "Вас успішно записано" for
// a couple of seconds, then hands control back to the coordinator, which returns
// the user to the salon profile. No network work — purely a timed handoff.

@MainActor
final class BookingSuccessViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        /// The splash finished showing — leave it (the pop is owned by the
        /// coordinator).
        let didFinish: () -> Void
    }

    /// How long the splash stays on screen before auto-dismissing (2–3s per design).
    private static let displayDuration: Duration = .seconds(2.5)

    private let transition: Transition

    init(transition: Transition) {
        self.transition = transition
        super.init()
    }

    // MARK: - Lifecycle

    override func onViewTask() async {
        do {
            try await Task.sleep(for: Self.displayDuration)
        } catch {
            // Cancelled because the view went away early — don't navigate.
            return
        }
        transition.didFinish()
    }
}
