import Moya
import Foundation
import Alamofire

// MARK: - SearchTarget

enum SearchTarget {
    case search(SearchRequestDTO)
    case pins(SearchRequestDTO)
    case filterOptions
    case history(limit: Int)
    case clearHistory
    case deleteHistoryItem(id: String)
}

// MARK: - TargetType

extension SearchTarget: TargetType {

    var baseURL: URL {
        return Environment.apiBaseURL
    }

    var path: String {
        switch self {
        case .search:
            return "/search"
        case .pins:
            return "/search/pins"
        case .filterOptions:
            return "/search/filter-options"
        case .history, .clearHistory:
            return "/search/history"
        case .deleteHistoryItem(let id):
            return "/search/history/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .search, .pins:
            return .post
        case .history, .filterOptions:
            return .get
        case .clearHistory, .deleteHistoryItem:
            return .delete
        }
    }

    var task: Moya.Task {
        switch self {
        case .search(let dto), .pins(let dto):
            return .requestJSONEncodable(dto)
        case .history(let limit):
            return .requestParameters(parameters: ["limit": limit], encoding: URLEncoding.default)
        case .filterOptions, .clearHistory, .deleteHistoryItem:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

// MARK: - AccessTokenAuthorizable

extension SearchTarget: AccessTokenAuthorizable {

    // Search + suggestions are public — the token is attached only when one
    // exists (unlocking `is_saved` / personalized suggestions). The history
    // endpoints require auth; the VM only calls them when a session exists.
    var authorizationType: AuthorizationType? {
        .bearer
    }
}
