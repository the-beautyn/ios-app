import Foundation
import MapKit

// MARK: - SearchMapClusterBuilder
//
// Pure grid clustering for the search map — stateless, directly unit-tested
// by `SearchMapClusteringTests`.

enum SearchMapClusterBuilder {

    /// Grid cells across the viewport — ≈50 pt per cell on a phone-width map,
    /// so pins closer than a fingertip merge into one bubble.
    private static let clusterGridDivisions = 8.0
    /// Cells with fewer pins than this stay individual dots — small groups
    /// read better as dots than as a tiny numbered bubble.
    private static let minClusterSize = 5

    /// Buckets pins into a viewport-relative grid: lone pins render as dots,
    /// denser cells as count bubbles. Keeps the annotation count bounded by
    /// the grid size regardless of how many pins the server returns.
    static func makeItems(pins: [SearchPin], viewport: SearchViewport) -> [SearchMapItem] {
        let cellLat = max(abs(viewport.latSpan), 0.000001) / clusterGridDivisions
        let cellLng = max(abs(viewport.lngSpan), 0.000001) / clusterGridDivisions

        var buckets: [String: [SearchPin]] = [:]
        for pin in pins {
            let row = Int(floor((pin.latitude - viewport.swLat) / cellLat))
            let column = Int(floor((pin.longitude - viewport.swLng) / cellLng))
            buckets["\(row):\(column)", default: []].append(pin)
        }

        return buckets
            .flatMap { key, cellPins -> [SearchMapItem] in
                if cellPins.count < minClusterSize {
                    return cellPins.map { pin in
                        .pin(SearchMapPin(
                            id: pin.id,
                            coordinate: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                        ))
                    }
                }
                let latitudes = cellPins.map(\.latitude)
                let longitudes = cellPins.map(\.longitude)
                return [.cluster(SearchMapCluster(
                    id: "cluster-\(key)",
                    coordinate: CLLocationCoordinate2D(
                        latitude: latitudes.reduce(0, +) / Double(cellPins.count),
                        longitude: longitudes.reduce(0, +) / Double(cellPins.count)
                    ),
                    count: cellPins.count,
                    minLat: latitudes.min() ?? 0,
                    maxLat: latitudes.max() ?? 0,
                    minLng: longitudes.min() ?? 0,
                    maxLng: longitudes.max() ?? 0
                ))]
            }
            .sorted { $0.id < $1.id }
    }
}
