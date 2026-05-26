import Combine
import Foundation
import os

struct ResetPasswordLinkModel {
    let email: String
    let code: String
}

struct SalonLinkModel {
    let salonId: String
}

protocol DeepLinkingService {
    var resetPasswordPublisher: AnyPublisher<ResetPasswordLinkModel, Never> { get }
    var salonLinkPublisher: AnyPublisher<SalonLinkModel, Never> { get }
    func handle(url: URL)
}

final class DeepLinkingServiceImpl: DeepLinkingService {
    private static let supportedHosts: Set<String> = [
        "api.beautyn.com.ua",
        "stage.beautyn.com.ua",
        "dev.beautyn.com.ua"
    ]

    private static let resetPasswordPath = "/auth/reset"
    private static let salonPathPrefix = "/salon/"

    private let resetPasswordSubject = PassthroughSubject<ResetPasswordLinkModel, Never>()
    private let salonLinkSubject = PassthroughSubject<SalonLinkModel, Never>()

    lazy var resetPasswordPublisher: AnyPublisher<ResetPasswordLinkModel, Never> = resetPasswordSubject.eraseToAnyPublisher()
    lazy var salonLinkPublisher: AnyPublisher<SalonLinkModel, Never> = salonLinkSubject.eraseToAnyPublisher()

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

        if components.path == Self.resetPasswordPath {
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
            return
        }

        if components.path.hasPrefix(Self.salonPathPrefix) {
            let salonId = String(components.path.dropFirst(Self.salonPathPrefix.count))
            guard !salonId.isEmpty, !salonId.contains("/") else {
                #if DEBUG
                os_log("[DeepLink] /salon/* missing or malformed id", type: .debug)
                #endif
                return
            }
            salonLinkSubject.send(SalonLinkModel(salonId: salonId))
            return
        }

        #if DEBUG
        os_log("[DeepLink] unknown path: %{public}@", type: .debug, components.path)
        #endif
    }
}
