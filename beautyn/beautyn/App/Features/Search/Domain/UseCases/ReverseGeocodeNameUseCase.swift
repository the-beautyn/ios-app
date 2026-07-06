import Foundation

// MARK: - ReverseGeocodeNameUseCase

protocol ReverseGeocodeNameUseCase {
    /// Human-readable name for a coordinate — `nil` when the lookup fails.
    func execute(_ point: GeoPoint) async -> String?
}

// MARK: - ReverseGeocodeNameUseCaseImpl

final class ReverseGeocodeNameUseCaseImpl: ReverseGeocodeNameUseCase {

    private let locationService: any SearchLocationService

    init(locationService: any SearchLocationService) {
        self.locationService = locationService
    }

    func execute(_ point: GeoPoint) async -> String? {
        await locationService.reverseGeocodeName(point)
    }
}
