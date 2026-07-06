import Foundation

// MARK: - ResolveInitialSearchRegionUseCase

/// Picks where the search map opens, trying in order:
///   1. the user's GPS location (asking for permission if needed),
///   2. the profile city, geocoded,
///   3. the device's region setting (Language & Region), geocoded,
///   4. Kyiv.
/// Every step falls through on denial/failure/timeout — never throws.
protocol ResolveInitialSearchRegionUseCase {
    func execute() async -> SearchRegion
}

// MARK: - ResolveInitialSearchRegionUseCaseImpl

final class ResolveInitialSearchRegionUseCaseImpl: ResolveInitialSearchRegionUseCase {

    private enum Span {
        static let userLocation: Double = 3_000
        static let city: Double = 10_000
        static let country: Double = 500_000
    }

    private let locationService: any SearchLocationService
    private let getCurrentUserUseCase: any GetCurrentUserUseCase
    private let sessionManager: SessionManager

    init(
        locationService: any SearchLocationService,
        getCurrentUserUseCase: any GetCurrentUserUseCase,
        sessionManager: SessionManager
    ) {
        self.locationService = locationService
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.sessionManager = sessionManager
    }

    func execute() async -> SearchRegion {
        if let location = await locationService.currentLocation() {
            return SearchRegion(center: location, spanMeters: Span.userLocation)
        }
        if let region = await resolveFromProfileCity() {
            return region
        }
        if let region = await resolveFromDeviceRegion() {
            return region
        }
        return .kyivFallback
    }

    // MARK: - Chain steps

    private func resolveFromProfileCity() async -> SearchRegion? {
        guard sessionManager.isAuthenticated,
              let city = try? await getCurrentUserUseCase.execute().city,
              !city.isEmpty,
              let center = await locationService.geocode(city) else { return nil }
        return SearchRegion(center: center, spanMeters: Span.city)
    }

    private func resolveFromDeviceRegion() async -> SearchRegion? {
        guard let regionCode = Locale.current.region?.identifier,
              let country = Locale.current.localizedString(forRegionCode: regionCode),
              let center = await locationService.geocode(country) else { return nil }
        return SearchRegion(center: center, spanMeters: Span.country)
    }
}
