import Foundation

// MARK: - StorageService

protocol StorageService {
    func retrieveValue<T: Codable>(for key: String) -> T?
    func storeValue<T: Codable>(_ value: T, for key: String)
    func removeValue(for key: String)
    func clearAll()
}

extension StorageService {
    func retrieveValue<T: Codable>(for key: String, default defaultValue: T) -> T {
        retrieveValue(for: key) ?? defaultValue
    }
}
