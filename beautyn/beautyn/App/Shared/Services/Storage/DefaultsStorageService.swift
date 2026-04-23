import Foundation

// MARK: - DefaultsKeys

enum DefaultsKeys {
    static let isAuthenticated = "beautyn.isAuthenticated"
    static let phoneVerificationRequired = "beautyn.phoneVerificationRequired"
    static let userProfile = "beautyn.userProfile"
}

// MARK: - DefaultsStorageService

struct DefaultsStorageService: StorageService {

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func retrieveValue<T: Codable>(for key: String) -> T? {
        if let rawData = userDefaults.object(forKey: key) as? Data {
            return try? JSONDecoder().decode([T].self, from: rawData).first
        }
        return userDefaults.object(forKey: key) as? T
    }

    func storeValue<T: Codable>(_ value: T, for key: String) {
        if PropertyListSerialization.propertyList(value, isValidFor: .xml) {
            userDefaults.set(value, forKey: key)
            return
        }

        if let rawData = try? JSONEncoder().encode([value]) {
            userDefaults.set(rawData, forKey: key)
        }
    }

    func removeValue(for key: String) {
        userDefaults.removeObject(forKey: key)
    }

    func clearAll() {
        userDefaults.dictionaryRepresentation().keys.forEach { key in
            removeValue(for: key)
        }
    }
}
