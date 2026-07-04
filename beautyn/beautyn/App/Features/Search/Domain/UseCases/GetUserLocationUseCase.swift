import Foundation

// MARK: - GetUserLocationUseCase

protocol GetUserLocationUseCase {
    /// One-shot GPS fix — `nil` when access is denied or the fix fails.
    func execute() async -> GeoPoint?
}

// MARK: - GetUserLocationUseCaseImpl

final class GetUserLocationUseCaseImpl: GetUserLocationUseCase {

    private let locationService: any SearchLocationService

    init(locationService: any SearchLocationService) {
        self.locationService = locationService
    }

    func execute() async -> GeoPoint? {
        await locationService.currentLocation()
    }
}
