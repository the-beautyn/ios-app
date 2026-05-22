import Foundation

// MARK: - ApiEnvelope

nonisolated struct ApiEnvelope<T: Decodable>: Decodable {
    let success: Bool?
    let data: T?
}

// MARK: - ApiErrorPayload

nonisolated struct ApiErrorPayload: Decodable {
    let message: String?
    let error: String?
    let statusCode: Int?
}
