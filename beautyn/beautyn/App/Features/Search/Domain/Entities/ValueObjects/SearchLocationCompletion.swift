import Foundation

// MARK: - SearchLocationCompletion

/// One autocomplete row for the Локація page — text only, no coordinate yet.
/// Resolving it (on tap) geocodes the actual `SearchLocation`. `id` is the
/// index into the service's completion batch identified by `batchId` — a
/// resolve against a superseded batch is refused (no-op) instead of silently
/// geocoding whatever row now sits at that index.
struct SearchLocationCompletion: Identifiable, Equatable {
    let id: Int
    let title: String
    let subtitle: String?
    let batchId: UUID
}
