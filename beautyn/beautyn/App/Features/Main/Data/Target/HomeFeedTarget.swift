import Moya
import Foundation
import Alamofire

// MARK: - HomeFeedTarget

enum HomeFeedTarget {
    case getHomeFeed(lat: Double?, lon: Double?)
}

// MARK: - TargetType

extension HomeFeedTarget: TargetType {

    var baseURL: URL {
        return Environment.apiBaseURL
    }

    var path: String {
        switch self {
        case .getHomeFeed:
            return "/home"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getHomeFeed:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .getHomeFeed(let lat, let lon):
            var params: [String: Any] = [:]
            if let lat { params["lat"] = lat }
            if let lon { params["lon"] = lon }
            if params.isEmpty {
                return .requestPlain
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

// MARK: - AccessTokenAuthorizable

extension HomeFeedTarget: AccessTokenAuthorizable {

    var authorizationType: AuthorizationType? {
        .bearer
    }
}
