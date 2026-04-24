import Moya
import Alamofire
import Foundation

// MARK: - UserTarget

enum UserTarget {
    case getMe
    case getSettings
    case updateNotifications(UpdateNotificationSettingsRequest)
}

// MARK: - TargetType

extension UserTarget: TargetType {

    var baseURL: URL {
        Environment.apiBaseURL
    }

    var path: String {
        switch self {
        case .getMe: return "/user/me"
        case .getSettings: return "/user/settings"
        case .updateNotifications: return "/user/settings/notifications"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getMe, .getSettings: return .get
        case .updateNotifications: return .patch
        }
    }

    var task: Moya.Task {
        switch self {
        case .getMe, .getSettings:
            return .requestPlain
        case .updateNotifications(let body):
            return .requestJSONEncodable(body)
        }
    }

    var headers: [String: String]? {
        ["Content-type": "application/json"]
    }
}

// MARK: - AccessTokenAuthorizable

extension UserTarget: AccessTokenAuthorizable {

    var authorizationType: AuthorizationType? {
        .bearer
    }
}
