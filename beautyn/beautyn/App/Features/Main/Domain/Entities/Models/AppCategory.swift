import Foundation

// MARK: - AppCategory

struct AppCategory: Identifiable {
    let id: String
    let slug: String
    let name: String
    let imageUrl: String?
    let sortOrder: Int?
}
