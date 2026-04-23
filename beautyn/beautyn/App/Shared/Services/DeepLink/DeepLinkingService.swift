import Combine
import Foundation
import os

struct ResetPasswordLinkModel {
    let email: String
    let code: String
}

protocol DeepLinkingService {
    var resetPasswordPublisher: AnyPublisher<ResetPasswordLinkModel, Never> { get }
    func handle(url: URL)
}

final class DeepLinkingServiceImpl: DeepLinkingService {
    private static let supportedHosts: Set<String> = [
        "api.beautyn.com.ua",
        "stage.beautyn.com.ua",
        "dev.beautyn.com.ua"
    ]

    private static let resetPasswordPath = "/auth/reset"

    private let resetPasswordSubject = PassthroughSubject<ResetPasswordLinkModel, Never>()

    lazy var resetPasswordPublisher: AnyPublisher<ResetPasswordLinkModel, Never> = resetPasswordSubject.eraseToAnyPublisher()

    func handle(url: URL) {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.scheme == "https",
            let host = components.host,
            Self.supportedHosts.contains(host)
        else {
            #if DEBUG
            os_log("[DeepLink] unsupported URL: %{public}@", type: .debug, url.absoluteString)
            #endif
            return
        }
        
        switch components.path {
        case Self.resetPasswordPath:
            guard
                let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
                let email = components.queryItems?.first(where: { $0.name == "email" })?.value
            else {
                #if DEBUG
                os_log("[DeepLink] /auth/reset missing email/code", type: .debug)
                #endif
                return
            }
            resetPasswordSubject.send(ResetPasswordLinkModel(email: email, code: code))
        default:
            #if DEBUG
            os_log("[DeepLink] unknown path: %{public}@", type: .debug, components.path)
            #endif
        }
    }
}
