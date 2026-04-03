import Moya
import Alamofire
import Foundation

// MARK: - NetworkService

protocol NetworkService {
    func request<D: Decodable>(_ target: Target, priority: TaskPriority?) async throws -> D
    func request(_ target: Target, priority: TaskPriority?) async throws
}

// MARK: - NetworkError

enum NetworkError: Error {
    case underlying(Error, Response)
    case decoding(Error, Response)
    case nilData(Response)
}

extension NetworkError: LocalizedError {
    var code: Int? {
        switch self {
        case let .underlying(_, response):
            return response.statusCode

        case .nilData, .decoding:
            return nil
        }
    }

    var errorDescription: String? {
        switch self {
        case let .underlying(_, response):
            return String(data: response.data, encoding: .utf8)

        case .nilData:
            return "No data"

        case let .decoding(error, _):
            #if DEBUG
            return "Decoding failed with " + error.localizedDescription
            #else
            return "Decoding failed"
            #endif
        }
    }

    var description: String {
        errorDescription ?? "Server error"
    }
}

// MARK: - NetworkServiceImpl

final class NetworkServiceImpl {

    private var provider: MoyaProvider<Target> {
        return MoyaProvider<Target>(plugins: handlePlugins())
    }

    private func request<D: Decodable>(
        _ target: Target,
        completion: @escaping (Result<D, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                #if DEBUG
                print("\n--> Request: \(response.request?.description ?? "nil")")
                print("\n<-- Response: \(String(data: response.data, encoding: .utf8) ?? "")\n *")
                #endif
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    let decoder = JSONDecoder()
                    let decodedResponse = try filteredResponse.map(ApiEnvelope<D>.self, using: decoder, failsOnEmptyData: false)
                    if let data = decodedResponse.data {
                        completion(.success(data))
                    } else {
                        completion(.failure(.nilData(response)))
                    }
                } catch {
                    if let error = error as? MoyaError {
                        switch error {
                        case .objectMapping(let error, let response):
                            completion(.failure(NetworkError.decoding(error, response)))
                        default:
                            completion(.failure(NetworkError.underlying(error, response)))
                        }
                    } else {
                        completion(.failure(NetworkError.underlying(error, response)))
                    }
                }

            case .failure(let error):
                completion(.failure(NetworkError.underlying(error, Response(statusCode: error.errorCode, data: Data()))))
            }
        }
    }

    private func request(
        _ target: Target,
        completion: @escaping (Result<Void, NetworkError>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                #if DEBUG
                print("\n--> Request: \(response.request?.description ?? "nil")")
                print("\n<-- Response: \(String(data: response.data, encoding: .utf8) ?? "")\n *")
                #endif
                do {
                    let _ = try response.filterSuccessfulStatusCodes()
                    completion(.success(Void()))
                } catch {
                    completion(.failure(NetworkError.underlying(error, response)))
                }

            case .failure(let error):
                completion(.failure(NetworkError.underlying(error, Response(statusCode: error.errorCode, data: Data()))))
            }
        }
    }

    private func handlePlugins() -> [PluginType] {
        var plugins = [PluginType]()
        plugins.append(NetworkLoggerPlugin())
        return plugins
    }
}

// MARK: - Default Parameters

extension NetworkService {
    func request<D: Decodable>(_ target: Target) async throws -> D {
        try await self.request(target, priority: .userInitiated)
    }

    func request(_ target: Target) async throws {
        try await self.request(target, priority: .userInitiated)
    }
}

// MARK: - NetworkServiceImpl + NetworkService

extension NetworkServiceImpl: NetworkService {
    func request<D: Decodable>(
        _ target: Target,
        priority: TaskPriority?
    ) async throws -> D {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<D, Error>) in
            _Concurrency.Task(priority: priority) {
                self.request(target) { (result: Result<D, NetworkError>) in
                    switch result {
                    case let .success(response):
                        continuation.resume(returning: response)

                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    func request(
        _ target: Target,
        priority: TaskPriority?
    ) async throws {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            _Concurrency.Task(priority: priority) {
                self.request(target) { (result: Result<Void, NetworkError>) in
                    switch result {
                    case let .success(response):
                        continuation.resume(returning: response)

                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
