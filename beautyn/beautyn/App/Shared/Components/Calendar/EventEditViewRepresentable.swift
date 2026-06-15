import SwiftUI
import EventKit
import EventKitUI

// MARK: - EventEditViewRepresentable
//
// Presents the system "Add Event" editor (`EKEventEditViewController`) so the
// user can review the prefilled event and pick which calendar account
// (Apple / Google / etc.) to save it to. Dismissal is driven by the SwiftUI
// binding: the delegate calls `onComplete`, which the caller uses to clear the
// `.sheet(item:)` source.

struct EventEditViewRepresentable: UIViewControllerRepresentable {

    let eventStore: EKEventStore
    let event: EKEvent
    let onComplete: () -> Void

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = eventStore
        controller.event = event
        controller.editViewDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: EKEventEditViewController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        private let onComplete: () -> Void

        init(onComplete: @escaping () -> Void) {
            self.onComplete = onComplete
        }

        func eventEditViewController(
            _ controller: EKEventEditViewController,
            didCompleteWith action: EKEventEditViewAction
        ) {
            onComplete()
        }
    }
}
