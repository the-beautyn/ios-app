import Foundation

// MARK: - CheckEmailSentViewModel

@MainActor
final class CheckEmailSentViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        let didClose: () -> Void
    }

    // MARK: - State

    let email: String

    // MARK: - Dependencies

    private let transition: Transition

    // MARK: - Init

    init(email: String, transition: Transition) {
        self.email = email
        self.transition = transition
        super.init()
    }

    // MARK: - Intents

    func didTapClose() { transition.didClose() }
}
