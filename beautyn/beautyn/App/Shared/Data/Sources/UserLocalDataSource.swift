import Foundation

// MARK: - UserLocalDataSource
//
// Sole owner of the `UserProfile` cache entry in local storage. Nothing else
// in the app should read or write `DefaultsKeys.userProfile` directly.

final class UserLocalDataSource {

    private let storage: StorageService

    init(storage: StorageService) {
        self.storage = storage
    }

    func get() -> UserProfile? {
        storage.retrieveValue(for: DefaultsKeys.userProfile)
    }

    func save(_ profile: UserProfile) {
        storage.storeValue(profile, for: DefaultsKeys.userProfile)
    }

    func clear() {
        storage.removeValue(for: DefaultsKeys.userProfile)
    }
}
