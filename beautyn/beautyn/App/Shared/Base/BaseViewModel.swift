import Foundation
import Combine

@MainActor
class BaseViewModel: ObservableObject {

    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var webPagePresentation: WebPagePresentation?

    func onAppear() {}

    func onViewTask() async {}

    func openWebView(url: URL, title: String? = nil) {
        webPagePresentation = WebPagePresentation(url: url, title: title)
    }
}

// MARK: - LoadableViewModel

extension BaseViewModel: LoadableViewModel {
    func showLoader() { isLoading = true }
    func hideLoader() { isLoading = false }
}

// MARK: - ErrorableViewModel

extension BaseViewModel: ErrorableViewModel {
    func showError(_ error: Error) {
        errorMessage = error.localizedDescription
    }
}

// MARK: - ViewModelLifecycle

extension BaseViewModel: ViewModelLifecycle {
    func onViewDidLoad() {}
    func onViewWillAppear() {}
    func onViewDidAppear() {}
    func onViewWillDisappear() {}
    func onViewDidDisappear() {}
}
