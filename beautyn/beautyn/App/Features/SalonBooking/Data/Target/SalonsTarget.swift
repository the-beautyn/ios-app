import Moya
import Foundation
import Alamofire

// MARK: - SalonInclude

enum SalonInclude: String, CaseIterable {
    case services
    case workers
    case categories
    case images

    static let all: Set<SalonInclude> = Set(SalonInclude.allCases)
}

// MARK: - SalonsTarget

enum SalonsTarget {
    case getSalonById(id: String, include: Set<SalonInclude>, isFromSearch: Bool)
    case getShare(id: String)
}

// MARK: - TargetType

extension SalonsTarget: TargetType {

    var baseURL: URL {
        return Environment.apiBaseURL
    }

    var path: String {
        switch self {
        case .getSalonById(let id, _, _):
            return "/salons/\(id)"
        case .getShare(let id):
            return "/salons/\(id)/share"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getSalonById, .getShare:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .getSalonById(_, let include, let isFromSearch):
            var parameters: [String: Any] = [:]
            if !include.isEmpty {
                parameters["include"] = include.map(\.rawValue).sorted().joined(separator: ",")
            }
            // Records a search-history visit server-side when a token is
            // attached; the backend ignores it for anonymous requests.
            if isFromSearch {
                parameters["isFromSearch"] = "true"
            }
            guard !parameters.isEmpty else { return .requestPlain }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getShare:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

// MARK: - AccessTokenAuthorizable

extension SalonsTarget: AccessTokenAuthorizable {

    var authorizationType: AuthorizationType? {
        .bearer
    }
}
