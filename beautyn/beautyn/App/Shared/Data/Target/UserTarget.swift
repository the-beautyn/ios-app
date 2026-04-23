import Moya
import Alamofire
import Foundation

// MARK: - UserTarget

enum UserTarget {
    case getMe
}

// MARK: - TargetType

extension UserTarget: TargetType {

    var baseURL: URL {
        Environment.apiBaseURL
    }

    var path: String {
        switch self {
        case .getMe: return "/user/me"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getMe: return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .getMe: return .requestPlain
        }
    }

    var headers: [String: String]? {
        ["Content-type": "application/json"]
    }
}

// MARK: - AccessTokenAuthorizable

extension UserTarget: AccessTokenAuthorizable {

    var authorizationType: AuthorizationType? {
        switch self {
        case .getMe: return .bearer
        }
    }
}
