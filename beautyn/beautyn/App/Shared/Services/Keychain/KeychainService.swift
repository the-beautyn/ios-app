import Foundation
import Security

// MARK: - KeychainKeys

enum KeychainKeys {
    static let accessToken = "beautyn.accessToken"
    static let refreshToken = "beautyn.refreshToken"
    static let appleUserID = "beautyn.appleUserID"
}

// MARK: - KeychainService

protocol KeychainService: StorageService {}

// MARK: - KeychainError

enum KeychainError: LocalizedError {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
    case unexpectedData

    var errorDescription: String? {
        switch self {
        case .saveFailed(let status): return "Keychain save failed: \(status)"
        case .loadFailed(let status): return "Keychain load failed: \(status)"
        case .deleteFailed(let status): return "Keychain delete failed: \(status)"
        case .unexpectedData: return "Unexpected keychain data format"
        }
    }
}

// MARK: - KeychainServiceImpl

final class KeychainServiceImpl: KeychainService {

    private func save(_ data: Data, for key: String) throws {
        try? delete(for: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    private func load(for key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.unexpectedData
            }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.loadFailed(status)
        }
    }

    private func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }

    // MARK: - StorageService

    func retrieveValue<T: Codable>(for key: String) -> T? {
        guard let data = try? load(for: key) else { return nil }
        if T.self == String.self {
            return String(data: data, encoding: .utf8) as? T
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func storeValue<T: Codable>(_ value: T, for key: String) {
        let data: Data
        if let string = value as? String {
            data = Data(string.utf8)
        } else if let encoded = try? JSONEncoder().encode(value) {
            data = encoded
        } else {
            return
        }
        try? save(data, for: key)
    }

    func removeValue(for key: String) {
        try? delete(for: key)
    }

    func clearAll() {
        try? delete(for: KeychainKeys.accessToken)
        try? delete(for: KeychainKeys.refreshToken)
        try? delete(for: KeychainKeys.appleUserID)
    }
}
