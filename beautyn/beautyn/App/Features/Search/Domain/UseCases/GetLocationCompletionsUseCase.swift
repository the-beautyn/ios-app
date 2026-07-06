import Foundation

// MARK: - GetLocationCompletionsUseCase

protocol GetLocationCompletionsUseCase {
    /// Autocomplete rows for a free-form place query — empty when nothing matches.
    func execute(query: String) async -> [SearchLocationCompletion]
}

// MARK: - GetLocationCompletionsUseCaseImpl

final class GetLocationCompletionsUseCaseImpl: GetLocationCompletionsUseCase {

    private let locationService: any SearchLocationService

    init(locationService: any SearchLocationService) {
        self.locationService = locationService
    }

    func execute(query: String) async -> [SearchLocationCompletion] {
        await locationService.locationCompletions(for: query)
    }
}
