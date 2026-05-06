import SwiftUI
import PopupView

struct AlertableViewModifier: ViewModifier {
    @Binding var alert: BeautynAlertContent?

    func body(content: Content) -> some View {
        content.popup(item: $alert) { item in
            BeautynAlertView(content: item)
        } customize: {
            $0
                .type(.floater(verticalPadding: 8, horizontalPadding: 0, useSafeAreaInset: true))
                .position(.top)
                .appearFrom(.topSlide)
                .animation(.spring(response: 0.45, dampingFraction: 0.8))
                .closeOnTap(true)
                .closeOnTapOutside(false)
                .dragToDismiss(true)
                .autohideIn(3.5)
                .dismissCallback { _ in alert = nil }
        }
    }
}

extension View {
    func alertable(alert: Binding<BeautynAlertContent?>) -> some View {
        modifier(AlertableViewModifier(alert: alert))
    }
}
