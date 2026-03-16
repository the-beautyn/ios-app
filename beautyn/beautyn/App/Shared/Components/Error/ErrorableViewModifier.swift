import SwiftUI

struct ErrorableViewModifier: ViewModifier {
    let errorMessage: String?
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        content.alert(
            Localization.errorTitle,
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { onDismiss() } }
            ),
            actions: {
                Button(Localization.okButton, role: .cancel) { onDismiss() }
            },
            message: {
                Text(errorMessage ?? "")
            }
        )
    }
}

extension View {
    func handleError(errorMessage: String?, onDismiss: @escaping () -> Void) -> some View {
        modifier(ErrorableViewModifier(errorMessage: errorMessage, onDismiss: onDismiss))
    }
}
