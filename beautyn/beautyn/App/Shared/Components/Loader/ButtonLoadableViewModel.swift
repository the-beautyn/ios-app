import Foundation

@MainActor
protocol ButtonLoadableViewModel: AnyObject {
    var isButtonLoading: Bool { get set }
    func showButtonLoader()
    func hideButtonLoader()
}

extension ButtonLoadableViewModel {
    func showButtonLoader() { isButtonLoading = true }
    func hideButtonLoader() { isButtonLoading = false }
}
