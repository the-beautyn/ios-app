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
    /// Bookable calendar days for the `[dateFrom, dateTo]` range (both
    /// `yyyy-MM-dd`). `serviceIds` and `workerId` narrow availability.
    case getBookableDates(salonId: String, serviceIds: [String], workerId: String?, dateFrom: String, dateTo: String)
    /// Available time slots for a single `date` (`yyyy-MM-dd`). `serviceIds` and
    /// `workerId` narrow availability.
    case getTimeSlots(salonId: String, date: String, workerId: String?, serviceIds: [String])
    /// Create the booking record. `workerId` nil = "any team member" (backend
    /// books with Altegio `staff_id: 0`). `comment` is optional.
    case createRecord(salonId: String, workerId: String?, serviceIds: [String], datetime: String, comment: String?)
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
        case .getBookableDates(let salonId, _, _, _, _):
            return "/booking/altegio/\(salonId)/dates"
        case .getTimeSlots(let salonId, _, _, _):
            return "/booking/altegio/\(salonId)/timeslots"
        case .createRecord(let salonId, _, _, _, _):
            return "/booking/altegio/\(salonId)/records"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getBookableServices, .getBookableWorkers, .getBookableDates, .getTimeSlots:
            return .get
        case .createRecord:
            return .post
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

        case .getBookableDates(_, let serviceIds, let workerId, let dateFrom, let dateTo):
            // The date range is always sent; `serviceIds` / `workerId` narrow it.
            var parameters: [String: Any] = [
                "dateFrom": dateFrom,
                "dateTo": dateTo
            ]
            if !serviceIds.isEmpty {
                parameters["serviceIds"] = serviceIds
            }
            if let workerId, !workerId.isEmpty {
                parameters["workerId"] = workerId
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)

        case .getTimeSlots(_, let date, let workerId, let serviceIds):
            // `date` is required by the backend; the rest narrow availability.
            var parameters: [String: Any] = ["date": date]
            if let workerId, !workerId.isEmpty {
                parameters["workerId"] = workerId
            }
            if !serviceIds.isEmpty {
                parameters["serviceIds"] = serviceIds
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)

        case .createRecord(_, let workerId, let serviceIds, let datetime, let comment):
            // JSON body. `serviceIds` + `datetime` are always sent; `workerId` is
            // omitted for "any team member"; `comment` is omitted when blank.
            var parameters: [String: Any] = [
                "serviceIds": serviceIds,
                "datetime": datetime
            ]
            if let workerId, !workerId.isEmpty {
                parameters["workerId"] = workerId
            }
            if let comment, !comment.isEmpty {
                parameters["comment"] = comment
            }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
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
