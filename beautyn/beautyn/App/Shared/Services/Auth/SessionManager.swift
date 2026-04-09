import Combine
import Foundation
import os

// MARK: - AuthState

enum AuthState {
    case unknown
    case authenticated
    case unauthenticated
}

// MARK: - SessionManager

@MainActor
final class SessionManager: ObservableObject {

    @Published private(set) var authState: AuthState = .unknown
    @Published private(set) var phoneVerificationRequired: Bool = false

    var isAuthenticated: Bool {
        authState == .authenticated && !phoneVerificationRequired
    }

    private let keychainService: KeychainService
    private let defaultsService: StorageService
    private let tokenLock = OSAllocatedUnfairLock<String?>(initialState: nil)

    init(keychainService: KeychainService, defaultsService: StorageService) {
        self.keychainService = keychainService
        self.defaultsService = defaultsService
    }

    func saveSession(accessToken: String, refreshToken: String, phoneVerificationRequired: Bool) {
        keychainService.storeValue(accessToken, for: KeychainKeys.accessToken)
        keychainService.storeValue(refreshToken, for: KeychainKeys.refreshToken)
        tokenLock.withLock { $0 = accessToken }
        self.phoneVerificationRequired = phoneVerificationRequired
        defaultsService.storeValue(true, for: DefaultsKeys.isAuthenticated)
        authState = .authenticated
    }

    func clearSession() {
        keychainService.removeValue(for: KeychainKeys.accessToken)
        keychainService.removeValue(for: KeychainKeys.refreshToken)
        tokenLock.withLock { $0 = nil }
        phoneVerificationRequired = false
        defaultsService.storeValue(false, for: DefaultsKeys.isAuthenticated)
        defaultsService.removeValue(for: DefaultsKeys.userProfile)
        authState = .unauthenticated
    }

    func restoreSession() {
        let isAuth: Bool = defaultsService.retrieveValue(for: DefaultsKeys.isAuthenticated, default: false)
        guard isAuth else {
            authState = .unauthenticated
            return
        }

        let accessToken: String? = keychainService.retrieveValue(for: KeychainKeys.accessToken)
        if let accessToken {
            tokenLock.withLock { $0 = accessToken }
        }

        // TODO: Wire actual /auth/refresh call when AuthTarget is integrated
        authState = .authenticated
    }
}

// MARK: - TokenProvider

extension SessionManager: TokenProvider {
    nonisolated var currentAccessToken: String? {
        tokenLock.withLock { $0 }
    }
}
