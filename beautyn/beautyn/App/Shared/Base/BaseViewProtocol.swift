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
            .handleError(errorMessage: viewModel.errorMessage) {
                viewModel.errorMessage = nil
            }
            .onAppear {
                viewModel.onAppear()
            }
            .task {
                await viewModel.onViewTask()
            }
    }
}
