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
                    set: { viewModel.webPagePresentation = $0 }
                ),
                content: WebPageView.init
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
