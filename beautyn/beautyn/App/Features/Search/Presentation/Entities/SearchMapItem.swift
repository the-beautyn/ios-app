import Foundation
import MapKit

// MARK: - SearchMapPin

/// A single salon dot on the search map.
struct SearchMapPin: Identifiable, Equatable {
    let id: String
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
            && lhs.coordinate.latitude == rhs.coordinate.latitude
            && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

// MARK: - SearchMapCluster

/// A count bubble standing in for a dense grid cell of pins.
struct SearchMapCluster: Identifiable, Equatable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let count: Int
    /// Bounding box of the clustered pins — the tap-to-zoom target.
    let minLat: Double
    let maxLat: Double
    let minLng: Double
    let maxLng: Double

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.count == rhs.count
            && lhs.coordinate.latitude == rhs.coordinate.latitude
            && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

// MARK: - SearchMapItem

/// What the map actually renders — a lone pin or a cluster bubble.
enum SearchMapItem: Identifiable, Equatable {
    case pin(SearchMapPin)
    case cluster(SearchMapCluster)

    var id: String {
        switch self {
        case .pin(let pin): return pin.id
        case .cluster(let cluster): return cluster.id
        }
    }
}
