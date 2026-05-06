import Foundation
import Combine

@MainActor
class BaseViewModel: ObservableObject {

    @Published private(set) var isLoading: Bool = false
    @Published var alert: BeautynAlertContent?
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

// MARK: - AlertableViewModel

extension BaseViewModel: AlertableViewModel {
    func showError(_ error: Error) {
        alert = .error(error.localizedDescription)
    }

    func showError(_ message: String) {
        alert = .error(message)
    }

    func showWarning(_ message: String) {
        alert = .warning(message)
    }

    func showSuccess(title: String, message: String) {
        alert = .success(title: title, message: message)
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
