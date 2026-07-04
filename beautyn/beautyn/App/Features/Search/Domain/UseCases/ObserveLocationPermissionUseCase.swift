import Combine
import Foundation

// MARK: - ObserveLocationPermissionUseCase

protocol ObserveLocationPermissionUseCase {
    /// Whether location access is denied/restricted — emits the current value
    /// immediately, then again on every authorization change.
    func execute() -> AnyPublisher<Bool, Never>
}

// MARK: - ObserveLocationPermissionUseCaseImpl

final class ObserveLocationPermissionUseCaseImpl: ObserveLocationPermissionUseCase {

    private let locationService: any SearchLocationService

    init(locationService: any SearchLocationService) {
        self.locationService = locationService
    }

    func execute() -> AnyPublisher<Bool, Never> {
        locationService.isPermissionDeniedPublisher
    }
}
