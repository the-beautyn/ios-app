import Foundation

protocol TokenProvider {
    var currentAccessToken: String? { get }
}
