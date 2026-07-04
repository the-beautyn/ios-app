import Moya
import Foundation
import Alamofire

// MARK: - SearchTarget

enum SearchTarget {
    case search(SearchRequestDTO)
    case pins(SearchRequestDTO)
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
        }
    }

    var method: Moya.Method {
        switch self {
        case .search, .pins:
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case .search(let dto), .pins(let dto):
            return .requestJSONEncodable(dto)
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

// MARK: - AccessTokenAuthorizable

extension SearchTarget: AccessTokenAuthorizable {

    // The endpoint is public; the token is attached only when one exists,
    // which unlocks the per-salon `is_saved` flag in the response.
    var authorizationType: AuthorizationType? {
        .bearer
    }
}
