import Foundation

@MainActor
protocol LoadableViewModel: AnyObject {
    var isLoading: Bool { get }
    func showLoader()
    func hideLoader()
}
