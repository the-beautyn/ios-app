import Foundation

// MARK: - ApiEnvelope

struct ApiEnvelope<T: Decodable>: Decodable {
    let success: Bool?
    let data: T?
}
