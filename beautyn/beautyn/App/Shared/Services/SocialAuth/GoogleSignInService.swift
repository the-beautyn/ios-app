import UIKit
import GoogleSignIn
import CryptoKit
import Security

// MARK: - GoogleSignInService

protocol GoogleSignInService {
    func signIn(presenting viewController: UIViewController) async throws -> GoogleSignInResult
}

struct GoogleSignInResult {
    let idToken: String
    let nonce: String
    let givenName: String?
    let familyName: String?
}

// MARK: - GoogleSignInError

enum GoogleSignInError: LocalizedError {
    case missingIDToken

    var errorDescription: String? {
        switch self {
        case .missingIDToken: return "Google Sign In: missing ID token"
        }
    }
}

// MARK: - GoogleSignInServiceImpl

final class GoogleSignInServiceImpl: GoogleSignInService {

    func signIn(presenting viewController: UIViewController) async throws -> GoogleSignInResult {
        let rawNonce = Self.randomNonceString()
        let hashedNonce = Self.sha256(rawNonce)
        let result: GIDSignInResult = try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(
                withPresenting: viewController,
                hint: nil,
                additionalScopes: nil,
                nonce: hashedNonce
            ) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: GoogleSignInError.missingIDToken)
                }
            }
        }
        guard let idToken = result.user.idToken?.tokenString else {
            throw GoogleSignInError.missingIDToken
        }
        return GoogleSignInResult(
            idToken: idToken,
            nonce: rawNonce,
            givenName: result.user.profile?.givenName,
            familyName: result.user.profile?.familyName
        )
    }

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
