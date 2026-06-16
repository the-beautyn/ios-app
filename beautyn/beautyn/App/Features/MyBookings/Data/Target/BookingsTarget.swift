import Moya
import Foundation
import Alamofire

// MARK: - BookingsTarget

enum BookingsTarget {
    case getBookings(
        status: String?,
        from: String?,
        to: String?,
        limit: Int?,
        cursor: String?,
        sort: String?
    )
    case getBookingById(id: String)
}

// MARK: - TargetType

extension BookingsTarget: TargetType {

    var baseURL: URL {
        return Environment.apiBaseURL
    }

    var path: String {
        switch self {
        case .getBookings:
            return "/bookings"
        case let .getBookingById(id):
            return "/bookings/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getBookings, .getBookingById:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .getBookings(status, from, to, limit, cursor, sort):
            var params: [String: Any] = [:]
            if let status { params["status"] = status }
            if let from { params["from"] = from }
            if let to { params["to"] = to }
            if let limit { params["limit"] = limit }
            if let cursor { params["cursor"] = cursor }
            if let sort { params["sort"] = sort }
            if params.isEmpty {
                return .requestPlain
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)

        case .getBookingById:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

// MARK: - AccessTokenAuthorizable

extension BookingsTarget: AccessTokenAuthorizable {

    var authorizationType: AuthorizationType? {
        .bearer
    }
}
