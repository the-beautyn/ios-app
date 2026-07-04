import Foundation

// MARK: - SearchRegion

/// Framework-agnostic map region: a center with a square span in meters.
/// The presentation layer converts it to MKCoordinateRegion.
struct SearchRegion: Equatable {
    let center: GeoPoint
    let spanMeters: Double

    /// Final fallback when no location source is available — Київ.
    static let kyivFallback = SearchRegion(
        center: GeoPoint(latitude: 50.4501, longitude: 30.5234),
        spanMeters: 10_000
    )
}
