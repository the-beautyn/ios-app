import UIKit

// MARK: - SearchControllerFactory

@MainActor
protocol SearchControllerFactory {
    func makeSearch(transition: SearchViewModel.Transition) -> UIViewController
}
