import Foundation

@MainActor
protocol ErrorableViewModel: AnyObject {
    var errorMessage: String? { get set }
    func showError(_ error: Error)
}
