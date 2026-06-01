import Moya
import Foundation
import Alamofire

// MARK: - AltegioBookingTarget
//
// Endpoints for the in-app Altegio booking flow. Today it exposes the bookable
// (available) services call; the remaining steps — workers, dates, time slots
// and record creation — will be added here as the flow grows.

enum AltegioBookingTarget {
    /// Services the salon can actually book right now. `selectedServiceIds` and
    /// `workerId` narrow availability (the response flags each service's
    /// `is_available`).
    case getBookableServices(salonId: String, selectedServiceIds: [String], workerId: String?)
}

// MARK: - TargetType

extension AltegioBookingTarget: TargetType {

    var baseURL: URL {
        return Environment.apiBaseURL
    }

    var path: String {
        switch self {
        case .getBookableServices(let salonId, _, _):
            return "/booking/altegio/\(salonId)/services"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getBookableServices:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .getBookableServices(_, let selectedServiceIds, let workerId):
            var parameters: [String: Any] = [:]
            // URLEncoding.default uses `.brackets` array encoding, producing
            // `selectedServiceIds[]=a&selectedServiceIds[]=b`, which is the key
            // the backend expects.
            if !selectedServiceIds.isEmpty {
                parameters["selectedServiceIds"] = selectedServiceIds
            }
            if let workerId, !workerId.isEmpty {
                parameters["workerId"] = workerId
            }
            guard !parameters.isEmpty else { return .requestPlain }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

// MARK: - AccessTokenAuthorizable

extension AltegioBookingTarget: AccessTokenAuthorizable {

    var authorizationType: AuthorizationType? {
        .bearer
    }
}
