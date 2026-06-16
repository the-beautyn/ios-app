import Moya
import Foundation
import Alamofire

// MARK: - EasyweekBookingTarget
//
// Endpoint for confirming a booking made in the EasyWeek web widget. The app
// scrapes the EasyWeek booking UUID from the widget's completion page and POSTs
// it here so the backend persists the booking locally and links it to the user.

enum EasyweekBookingTarget {
    /// Confirm + persist a completed EasyWeek widget booking.
    case confirm(salonId: String, bookingUuid: String)
}

// MARK: - TargetType

extension EasyweekBookingTarget: TargetType {

    var baseURL: URL {
        return Environment.apiBaseURL
    }

    var path: String {
        switch self {
        case .confirm:
            return "/bookings/easyweek/confirm"
        }
    }

    var method: Moya.Method {
        switch self {
        case .confirm:
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case let .confirm(salonId, bookingUuid):
            // snake_case JSON body, matching the backend convention.
            return .requestParameters(
                parameters: [
                    "salon_id": salonId,
                    "booking_uuid": bookingUuid
                ],
                encoding: JSONEncoding.default
            )
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

// MARK: - AccessTokenAuthorizable

extension EasyweekBookingTarget: AccessTokenAuthorizable {

    var authorizationType: AuthorizationType? {
        .bearer
    }
}
