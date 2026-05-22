import AuthenticationServices
import CryptoKit
import Foundation
import UIKit

// MARK: - AppleSignInService

protocol AppleSignInService {
    func signIn() async throws -> AppleSignInResult
}

struct AppleSignInResult {
    let idToken: String
    let nonce: String
    let fullName: PersonNameComponents?
}

// MARK: - AppleSignInServiceImpl

final class AppleSignInServiceImpl: NSObject, AppleSignInService {

    private let keychainService: KeychainService
    private var continuation: CheckedContinuation<AppleSignInResult, Error>?

    init(keychainService: KeychainService) {
        self.keychainService = keychainService
    }

    func signIn() async throws -> AppleSignInResult {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let nonce = Self.randomNonceString()
            let hashedNonce = Self.sha256(nonce)

            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = hashedNonce

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self

            // Store raw nonce for later
            objc_setAssociatedObject(controller, &Self.nonceKey, nonce, .OBJC_ASSOCIATION_RETAIN)

            controller.performRequests()
        }
    }

    // MARK: - Apple User ID persistence

    func saveAppleUserID(_ userID: String) {
        keychainService.storeValue(userID, for: KeychainKeys.appleUserID)
    }

    func loadAppleUserID() -> String? {
        return keychainService.retrieveValue(for: KeychainKeys.appleUserID)
    }

    // MARK: - Nonce helpers

    private static var nonceKey: UInt8 = 0

    private static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        precondition(errorCode == errSecSuccess)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleSignInServiceImpl: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            continuation?.resume(throwing: AppleSignInError.missingToken)
            continuation = nil
            return
        }

        let nonce = objc_getAssociatedObject(controller, &Self.nonceKey) as? String ?? ""

        // Save Apple User ID for credential revocation checks
        saveAppleUserID(credential.user)

        let result = AppleSignInResult(
            idToken: idToken,
            nonce: nonce,
            fullName: credential.fullName
        )
        continuation?.resume(returning: result)
        continuation = nil
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleSignInServiceImpl: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }

        guard let scene = scenes.first(where: { $0.activationState == .foregroundActive })
                ?? scenes.first else {
            preconditionFailure("No UIWindowScene available for Apple Sign In presentation")
        }

        return scene.windows.first(where: \.isKeyWindow)
            ?? ASPresentationAnchor(windowScene: scene)
    }
}

// MARK: - AppleSignInError

enum AppleSignInError: LocalizedError {
    case missingToken

    var errorDescription: String? {
        switch self {
        case .missingToken: return "Apple Sign In: missing identity token"
        }
    }
}
