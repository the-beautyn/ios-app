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
    case getSalonById(id: String, include: Set<SalonInclude>)
    case getShare(id: String)
}

// MARK: - TargetType

extension SalonsTarget: TargetType {

    var baseURL: URL {
        return Environment.apiBaseURL
    }

    var path: String {
        switch self {
        case .getSalonById(let id, _):
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
        case .getSalonById(_, let include):
            guard !include.isEmpty else { return .requestPlain }
            let value = include.map(\.rawValue).sorted().joined(separator: ",")
            return .requestParameters(parameters: ["include": value], encoding: URLEncoding.default)
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
