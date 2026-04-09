import Moya
import Foundation
import Alamofire

// MARK: - AuthTarget

enum AuthTarget {
    case checkEmail(email: String)
    case login(email: String, password: String)
    case register(email: String, password: String, name: String, secondName: String, role: String)
    case oauth(provider: String, idToken: String, nonce: String?, name: String?, secondName: String?)
    case refreshToken(refreshToken: String)
    case logout
    case forgotPassword(email: String)
    case sendPhoneOTP(phone: String)
    case verifyPhoneOTP(phone: String, code: String)
    case resendPhoneOTP(phone: String)
}

// MARK: - TargetType

extension AuthTarget: TargetType {

    var baseURL: URL {
        return Environment.apiBaseURL
    }

    var path: String {
        switch self {
        case .checkEmail: return "/auth/check-email"
        case .login: return "/auth/login"
        case .register: return "/auth/register"
        case .oauth: return "/auth/oauth"
        case .refreshToken: return "/auth/refresh"
        case .logout: return "/auth/logout"
        case .forgotPassword: return "/auth/forgot-password"
        case .sendPhoneOTP: return "/auth/phone/send-otp"
        case .verifyPhoneOTP: return "/auth/phone/verify-otp"
        case .resendPhoneOTP: return "/auth/phone/resend-otp"
        }
    }

    var method: Moya.Method {
        return .post
    }

    var task: Moya.Task {
        switch self {
        case .checkEmail(let email):
            return .requestParameters(
                parameters: ["email": email],
                encoding: JSONEncoding.default
            )

        case .login(let email, let password):
            return .requestParameters(
                parameters: ["email": email, "password": password],
                encoding: JSONEncoding.default
            )

        case .register(let email, let password, let name, let secondName, let role):
            return .requestParameters(
                parameters: [
                    "email": email,
                    "password": password,
                    "name": name,
                    "secondName": secondName,
                    "role": role
                ],
                encoding: JSONEncoding.default
            )

        case .oauth(let provider, let idToken, let nonce, let name, let secondName):
            var params: [String: Any] = [
                "provider": provider,
                "idToken": idToken
            ]
            if let nonce { params["nonce"] = nonce }
            if let name { params["name"] = name }
            if let secondName { params["secondName"] = secondName }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case .refreshToken(let refreshToken):
            return .requestParameters(
                parameters: ["refreshToken": refreshToken],
                encoding: JSONEncoding.default
            )

        case .logout:
            return .requestPlain

        case .forgotPassword(let email):
            return .requestParameters(
                parameters: ["email": email],
                encoding: JSONEncoding.default
            )

        case .sendPhoneOTP(let phone):
            return .requestParameters(
                parameters: ["phone": phone],
                encoding: JSONEncoding.default
            )

        case .verifyPhoneOTP(let phone, let code):
            return .requestParameters(
                parameters: ["phone": phone, "code": code],
                encoding: JSONEncoding.default
            )

        case .resendPhoneOTP(let phone):
            return .requestParameters(
                parameters: ["phone": phone],
                encoding: JSONEncoding.default
            )
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

// MARK: - AccessTokenAuthorizable

extension AuthTarget: AccessTokenAuthorizable {

    var authorizationType: AuthorizationType? {
        switch self {
        case .logout, .sendPhoneOTP, .verifyPhoneOTP, .resendPhoneOTP:
            return .bearer
        default:
            return nil
        }
    }
}
