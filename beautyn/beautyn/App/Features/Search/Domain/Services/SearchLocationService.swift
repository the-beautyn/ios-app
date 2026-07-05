import Combine
import Foundation

// MARK: - SearchLocationService

/// Domain contract for platform location and geocoding — implemented in the
/// Data layer (CoreLocation / MapKit). Exposes Domain value types only.
@MainActor
protocol SearchLocationService {
    /// Whether location access is denied/restricted — emits the current value
    /// immediately, then again on every authorization change.
    var isPermissionDeniedPublisher: AnyPublisher<Bool, Never> { get }

    /// One-shot GPS fix (asking for permission when undetermined) —
    /// `nil` when access is denied or the fix fails/times out.
    func currentLocation() async -> GeoPoint?

    /// Forward-geocodes a free-form address / city / country name —
    /// `nil` when nothing matches or the lookup fails.
    func geocode(_ address: String) async -> GeoPoint?

    /// Autocomplete for a free-form place query (addresses, cities, POIs) —
    /// text-only rows; empty when nothing matches or the lookup fails.
    func locationCompletions(for query: String) async -> [SearchLocationCompletion]

    /// Geocodes a previously returned completion into an actual place —
    /// `nil` when the completion is stale or the lookup fails.
    func resolveLocation(_ completion: SearchLocationCompletion) async -> SearchLocation?

    /// Human-readable name for a coordinate (city with context) — `nil`
    /// when reverse geocoding fails.
    func reverseGeocodeName(_ point: GeoPoint) async -> String?
}
