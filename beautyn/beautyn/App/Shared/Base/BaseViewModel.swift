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
    func showError(_ error: Error, scope: AlertScope) {
        present(.error(error.localizedDescription), scope: scope)
    }

    func showError(_ message: String, scope: AlertScope) {
        present(.error(message), scope: scope)
    }

    func showWarning(_ message: String, scope: AlertScope) {
        present(.warning(message), scope: scope)
    }

    func showSuccess(_ message: String, scope: AlertScope) {
        present(.success(message), scope: scope)
    }

    func showSuccess(title: String, message: String, scope: AlertScope) {
        present(.success(title: title, message: message), scope: scope)
    }

    private func present(_ content: BeautynAlertContent, scope: AlertScope) {
        switch scope {
        case .current: alert = content
        case .global: AlertRelay.shared.enqueue(content)
        }
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
