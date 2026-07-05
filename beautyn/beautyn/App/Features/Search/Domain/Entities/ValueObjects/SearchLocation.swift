import Foundation

// MARK: - SearchLocationKind

/// What kind of place the user picked — drives the search radius on the
/// backend (`locationType`) and the map zoom. Raw values match the API enum.
enum SearchLocationKind: String {
    case city
    case neighborhood
    case address
    case poi
    case unknown
}

// MARK: - SearchLocation

/// A concrete place the user can center a search on — a geocoded point with
/// the human-readable name shown in the location pill.
struct SearchLocation: Equatable {
    let point: GeoPoint
    let name: String
    /// Extra context for picker rows (e.g. "Київ, Україна"); not shown in the pill.
    let subtitle: String?
    let kind: SearchLocationKind

    init(point: GeoPoint, name: String, subtitle: String? = nil, kind: SearchLocationKind = .unknown) {
        self.point = point
        self.name = name
        self.subtitle = subtitle
        self.kind = kind
    }
}
