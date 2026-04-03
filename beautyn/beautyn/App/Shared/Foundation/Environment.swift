import Foundation

// MARK: - Environment

public enum Environment {

    // MARK: - Keys

    enum Keys {
        static let environmentType = "EnvironmentType"
        static let apiScheme = "ApiScheme"
        static let apiHost = "ApiHost"
        static let apiPathPrefix = "ApiPathPrefix"
    }

    // MARK: - Info Dictionary

    private static let infoDictionary: [String: Any] = {
        guard let dic = Bundle.main.infoDictionary else {
            fatalError("Info.plist not found")
        }
        return dic
    }()

    // MARK: - Properties

    static var environmentType: String {
        guard let type = infoDictionary[Keys.environmentType] as? String else {
            fatalError("EnvironmentType not found in Info.plist")
        }
        return type
    }

    static var apiBaseURL: URL {
        guard let scheme = infoDictionary[Keys.apiScheme] as? String,
              let host = infoDictionary[Keys.apiHost] as? String,
              let pathPrefix = infoDictionary[Keys.apiPathPrefix] as? String else {
            fatalError("API URL components not found in Info.plist")
        }

        var components = URLComponents()
        components.scheme = scheme
        components.host = host.components(separatedBy: ":").first
        if let portString = host.components(separatedBy: ":").dropFirst().first,
           let port = Int(portString) {
            components.port = port
        }
        components.path = "/\(pathPrefix)"

        guard let url = components.url else {
            fatalError("Failed to construct API base URL")
        }
        return url
    }

    static var isProduction: Bool {
        environmentType == "Production"
    }

    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
