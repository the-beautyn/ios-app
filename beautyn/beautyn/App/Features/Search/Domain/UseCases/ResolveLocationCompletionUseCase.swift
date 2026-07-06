import Foundation

// MARK: - ResolveLocationCompletionUseCase

protocol ResolveLocationCompletionUseCase {
    /// Geocodes a tapped completion into an actual place — `nil` when the
    /// completion is stale or the lookup fails.
    func execute(_ completion: SearchLocationCompletion) async -> SearchLocation?
}

// MARK: - ResolveLocationCompletionUseCaseImpl

final class ResolveLocationCompletionUseCaseImpl: ResolveLocationCompletionUseCase {

    private let locationService: any SearchLocationService

    init(locationService: any SearchLocationService) {
        self.locationService = locationService
    }

    func execute(_ completion: SearchLocationCompletion) async -> SearchLocation? {
        await locationService.resolveLocation(completion)
    }
}
