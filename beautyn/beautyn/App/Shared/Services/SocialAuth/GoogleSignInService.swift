import UIKit
import GoogleSignIn

// MARK: - GoogleSignInService

protocol GoogleSignInService {
    func signIn(presenting viewController: UIViewController) async throws -> GoogleSignInResult
}

struct GoogleSignInResult {
    let idToken: String
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
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        guard let idToken = result.user.idToken?.tokenString else {
            throw GoogleSignInError.missingIDToken
        }
        return GoogleSignInResult(idToken: idToken)
    }
}
