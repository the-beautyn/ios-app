import Foundation

// MARK: - UserSettingsRepositoryImpl

final class UserSettingsRepositoryImpl: UserSettingsRepository {

    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func fetchSettings() async throws -> UserSettings {
        let target = Target(type: UserTarget.getSettings)
        let dto: UserSettingsDTO = try await networkService.request(target)
        return UserSettingsMapper.map(dto)
    }

    func updateNotifications(
        pushEnabled: Bool?,
        emailEnabled: Bool?,
        smsEnabled: Bool?
    ) async throws -> UserSettings {
        let body = UpdateNotificationSettingsRequest(
            pushEnabled: pushEnabled,
            emailEnabled: emailEnabled,
            smsEnabled: smsEnabled
        )
        let target = Target(type: UserTarget.updateNotifications(body))
        let dto: UserSettingsDTO = try await networkService.request(target)
        return UserSettingsMapper.map(dto)
    }
}
