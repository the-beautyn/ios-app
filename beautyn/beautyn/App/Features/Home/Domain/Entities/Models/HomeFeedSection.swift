import Foundation

// MARK: - HomeFeedSection

struct HomeFeedSection: Identifiable {
    let id: String
    let type: String
    let title: String
    let emoji: String?
    let items: [SalonCard]
}
