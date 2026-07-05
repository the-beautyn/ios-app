import UIKit

// MARK: - SearchControllerFactory

@MainActor
protocol SearchControllerFactory {
    func makeSearchMap(transition: SearchMapViewModel.Transition) -> UIViewController
    func makeSearch(context: SearchInputContext, transition: SearchViewModel.Transition) -> UIViewController
    func makeSearchLocation(transition: SearchLocationViewModel.Transition) -> UIViewController
}
