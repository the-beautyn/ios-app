import Moya
import Foundation
import Alamofire

// MARK: - AltegioBookingTarget
//
// Endpoints for the in-app Altegio booking flow. Today it exposes the bookable
// (available) services call; the remaining steps — workers, dates, time slots
// and record creation — will be added here as the flow grows.

enum AltegioBookingTarget {
    /// Services the salon can actually book right now. `selectedServiceIds`,
    /// `workerId` and `datetime` narrow availability (the response flags each
    /// service's `is_available`).
    case getBookableServices(salonId: String, selectedServiceIds: [String], workerId: String?, datetime: String?)
    /// Workers the salon can book. `serviceIds` and `datetime` narrow
    /// availability; `includeSlots` adds each worker's next available slots.
    case getBookableWorkers(salonId: String, serviceIds: [String], datetime: String?, includeSlots: Bool)
}

// MARK: - TargetType

extension AltegioBookingTarget: TargetType {

    var baseURL: URL {
        return Environment.apiBaseURL
    }

    var path: String {
        switch self {
        case .getBookableServices(let salonId, _, _, _):
            return "/booking/altegio/\(salonId)/services"
        case .getBookableWorkers(let salonId, _, _, _):
            return "/booking/altegio/\(salonId)/workers"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getBookableServices, .getBookableWorkers:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .getBookableServices(_, let selectedServiceIds, let workerId, let datetime):
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
            if let datetime, !datetime.isEmpty {
                parameters["datetime"] = datetime
            }
            guard !parameters.isEmpty else { return .requestPlain }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)

        case .getBookableWorkers(_, let serviceIds, let datetime, let includeSlots):
            var parameters: [String: Any] = [:]
            // Same bracket array encoding as services — backend expects
            // `serviceIds[]=a&serviceIds[]=b`.
            if !serviceIds.isEmpty {
                parameters["serviceIds"] = serviceIds
            }
            if let datetime, !datetime.isEmpty {
                parameters["datetime"] = datetime
            }
            if includeSlots {
                parameters["includeSlots"] = true
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
