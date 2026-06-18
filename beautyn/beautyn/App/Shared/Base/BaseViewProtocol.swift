import SwiftUI

@MainActor
protocol BaseViewProtocol: View {
    associatedtype Content: View
    associatedtype VM: BaseViewModel

    var viewModel: VM { get }

    @ViewBuilder var contentView: Content { get }
}

extension BaseViewProtocol {
    var body: some View {
        contentView
            .loader(isLoading: viewModel.isLoading)
            .alertable(alert: Binding(
                get: { viewModel.alert },
                set: { viewModel.alert = $0 }
            ))
            .sheet(
                item: Binding<WebPagePresentation?>(
                    get: { viewModel.webPagePresentation },
                    // SwiftUI writes back through this setter only on user dismissal
                    // (Done / swipe); a programmatic clear writes the VM directly and
                    // skips it. So firing onDismiss here means "the user closed it".
                    set: { newValue in
                        if newValue == nil { viewModel.webPagePresentation?.onDismiss?() }
                        viewModel.webPagePresentation = newValue
                    }
                ),
                content: WebPageView.init
            )
            .sheet(
                item: Binding<WebBookingPresentation?>(
                    get: { viewModel.webBookingPresentation },
                    set: { newValue in
                        if newValue == nil { viewModel.webBookingPresentation?.onDismiss?() }
                        viewModel.webBookingPresentation = newValue
                    }
                ),
                content: WebBookingView.init
            )
            .onAppear {
                if let pending = AlertRelay.shared.consume() {
                    viewModel.alert = pending
                }
                viewModel.onAppear()
            }
            .task {
                await viewModel.onViewTask()
            }
    }
}
