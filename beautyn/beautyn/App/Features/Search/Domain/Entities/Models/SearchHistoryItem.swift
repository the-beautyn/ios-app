import Foundation

// MARK: - SearchHistoryItem

/// One previously visited salon from the user's search history.
/// `id` is the history row id (the deletion key), not the salon id.
struct SearchHistoryItem: Identifiable, Equatable {
    let id: String
    let salonId: String
    let name: String
    let city: String
    let imageUrl: String?
    /// Salon coordinate — lets the map zoom straight to a picked salon.
    let point: GeoPoint?
}
