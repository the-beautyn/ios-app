import Moya
import Foundation
import Alamofire

// MARK: - SavedSalonsTarget

enum SavedSalonsTarget {
    case list(q: String?, page: Int?, limit: Int?)
    case save(salonId: String)
    case unsave(salonId: String)
}

// MARK: - TargetType

extension SavedSalonsTarget: TargetType {

    var baseURL: URL {
        return Environment.apiBaseURL
    }

    var path: String {
        switch self {
        case .list:
            return "/saved-salons"
        case .save(let salonId), .unsave(let salonId):
            return "/saved-salons/\(salonId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .list:   return .get
        case .save:   return .post
        case .unsave: return .delete
        }
    }

    var task: Moya.Task {
        switch self {
        case .list(let q, let page, let limit):
            var params: [String: Any] = [:]
            if let q, !q.isEmpty { params["q"] = q }
            if let page { params["page"] = page }
            if let limit { params["limit"] = limit }
            if params.isEmpty {
                return .requestPlain
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)

        case .save, .unsave:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

// MARK: - AccessTokenAuthorizable

extension SavedSalonsTarget: AccessTokenAuthorizable {

    var authorizationType: AuthorizationType? {
        .bearer
    }
}
