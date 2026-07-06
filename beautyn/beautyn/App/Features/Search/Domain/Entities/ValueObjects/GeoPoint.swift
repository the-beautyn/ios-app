import Foundation

// MARK: - GeoPoint

/// Framework-agnostic coordinate — the Domain's stand-in for CLLocationCoordinate2D.
struct GeoPoint: Equatable {
    let latitude: Double
    let longitude: Double
}
