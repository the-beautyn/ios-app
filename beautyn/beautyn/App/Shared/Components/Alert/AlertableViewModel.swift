import Foundation

@MainActor
protocol AlertableViewModel: AnyObject {
    var alert: BeautynAlertContent? { get set }

    func showError(_ error: Error)
    func showError(_ message: String)
    func showWarning(_ message: String)
    func showSuccess(title: String, message: String)
}
