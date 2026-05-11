import Foundation

enum AlertScope {
    case current
    case global
}

@MainActor
protocol AlertableViewModel: AnyObject {
    var alert: BeautynAlertContent? { get set }

    func showError(_ error: Error, scope: AlertScope)
    func showError(_ message: String, scope: AlertScope)
    func showWarning(_ message: String, scope: AlertScope)
    func showSuccess(_ message: String, scope: AlertScope)
    func showSuccess(title: String, message: String, scope: AlertScope)
}

@MainActor
extension AlertableViewModel {
    func showError(_ error: Error) { showError(error, scope: .current) }
    func showError(_ message: String) { showError(message, scope: .current) }
    func showWarning(_ message: String) { showWarning(message, scope: .current) }
    func showSuccess(_ message: String) { showSuccess(message, scope: .current) }
    func showSuccess(title: String, message: String) {
        showSuccess(title: title, message: message, scope: .current)
    }
}
