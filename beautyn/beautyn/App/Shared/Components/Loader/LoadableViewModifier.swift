import SwiftUI

struct LoadableViewModifier: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        content.overlay {
            if isLoading {
                LoaderView()
            }
        }
    }
}

extension View {
    func loader(isLoading: Bool) -> some View {
        modifier(LoadableViewModifier(isLoading: isLoading))
    }
}
