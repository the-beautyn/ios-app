import Foundation

enum AppError: Error, LocalizedError {
    case network(NetworkError)
    case parsing(Error)
    case unknown(Error?)
    case custom(String)

    enum NetworkError {
        case invalidResponse
        case statusCode(Int)
        case noConnection
        case timeout
    }

    var errorDescription: String? {
        switch self {
        case .network(.invalidResponse):
            return Localization.errorInvalidResponse
        case .network(.statusCode(let code)):
            return Localization.errorServer(code)
        case .network(.noConnection):
            return Localization.errorNoConnection
        case .network(.timeout):
            return Localization.errorTimeout
        case .parsing(let error):
            return Localization.errorData(error.localizedDescription)
        case .unknown(let error):
            return error?.localizedDescription ?? Localization.errorUnknown
        case .custom(let message):
            return message
        }
    }
}
