import SwiftUI

/// Standalone error alert presenter.
/// Prefer the `.handleError(errorMessage:onDismiss:)` modifier for typical ViewModel binding.
struct ErrorAlertView: ViewModifier {
    @Binding var errorMessage: String?

    func body(content: Content) -> some View {
        content.alert(
            Localization.errorTitle,
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            ),
            actions: {
                Button(Localization.okButton, role: .cancel) { errorMessage = nil }
            },
            message: {
                Text(errorMessage ?? "")
            }
        )
    }
}

extension View {
    func errorAlert(errorMessage: Binding<String?>) -> some View {
        modifier(ErrorAlertView(errorMessage: errorMessage))
    }
}
