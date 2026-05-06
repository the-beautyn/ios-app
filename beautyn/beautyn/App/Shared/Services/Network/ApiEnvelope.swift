import Foundation

// MARK: - ApiEnvelope

struct ApiEnvelope<T: Decodable>: Decodable {
    let success: Bool?
    let data: T?
}

// MARK: - ApiErrorPayload

struct ApiErrorPayload: Decodable {
    let message: String?
    let error: String?
    let statusCode: Int?
}
