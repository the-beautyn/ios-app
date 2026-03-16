import Foundation

// MARK: - HTTPMethod

enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}

// MARK: - Endpoint

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var parameters: [String: Any]? { get }
}

// MARK: - NetworkService

protocol NetworkService {
    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T
}

// MARK: - URLSessionNetworkService

final class URLSessionNetworkService: NetworkService {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T {
        let urlRequest = try buildRequest(from: endpoint)
        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.network(.invalidResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw AppError.network(.statusCode(httpResponse.statusCode))
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw AppError.parsing(error)
        }
    }

    private func buildRequest(from endpoint: any Endpoint) throws -> URLRequest {
        let url = endpoint.baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        if let params = endpoint.parameters, endpoint.method != .get {
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}
