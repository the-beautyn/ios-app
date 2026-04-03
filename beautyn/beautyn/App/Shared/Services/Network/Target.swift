import Moya
import Foundation

struct Target {
    let type: TargetType
}

extension Target: TargetType {
    var baseURL: URL {
        return type.baseURL
    }

    var path: String {
        return type.path
    }

    var method: Moya.Method {
        return type.method
    }

    var task: Task {
        return type.task
    }

    var sampleData: Data {
        return type.sampleData
    }

    var headers: [String: String]? {
        return type.headers
    }
}

extension Target: AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        guard let type = type as? AccessTokenAuthorizable else { return nil }
        return type.authorizationType
    }
}
