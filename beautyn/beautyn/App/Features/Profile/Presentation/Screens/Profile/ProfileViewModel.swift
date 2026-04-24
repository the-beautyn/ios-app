import Combine
import Foundation

// MARK: - ProfileViewModel

@MainActor
final class ProfileViewModel: BaseViewModel {

    struct Transition {
        let didTapPersonalData: () -> Void
        let didTapSavedSalons: () -> Void
        let didTapSettings: () -> Void
        let didTapLanguage: () -> Void
    }

    @Published private(set) var avatarURL: URL?
    @Published private(set) var notificationsEnabled: Bool = true

    private let transition: Transition
    private let getCurrentUserUseCase: any GetCurrentUserUseCase
    private let getUserSettingsUseCase: any GetUserSettingsUseCase
    private let updateNotificationSettingsUseCase: any UpdateNotificationSettingsUseCase

    init(
        transition: Transition,
        getCurrentUserUseCase: any GetCurrentUserUseCase,
        getUserSettingsUseCase: any GetUserSettingsUseCase,
        updateNotificationSettingsUseCase: any UpdateNotificationSettingsUseCase
    ) {
        self.transition = transition
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.getUserSettingsUseCase = getUserSettingsUseCase
        self.updateNotificationSettingsUseCase = updateNotificationSettingsUseCase
        super.init()
        Task { [weak self] in
            await self?.loadAvatar()
            await self?.loadSettings()
        }
    }

    // MARK: - Actions

    func setNotificationsEnabled(_ enabled: Bool) {
        let previous = notificationsEnabled
        notificationsEnabled = enabled
        Task {
            do {
                let updated = try await updateNotificationSettingsUseCase.execute(
                    pushEnabled: enabled,
                    emailEnabled: nil,
                    smsEnabled: nil
                )
                notificationsEnabled = updated.notifications.pushEnabled
            } catch {
                notificationsEnabled = previous
                showError(error)
            }
        }
    }

    func didTapPersonalData() { transition.didTapPersonalData() }
    func didTapSavedSalons() { transition.didTapSavedSalons() }
    func didTapSettings() { transition.didTapSettings() }
    func didTapLanguage() { transition.didTapLanguage() }

    // MARK: - Private

    private func loadAvatar() async {
        if let urlString = try? await getCurrentUserUseCase.execute().avatarUrl {
            avatarURL = URL(string: urlString)
        }
    }

    private func loadSettings() async {
        do {
            let settings = try await getUserSettingsUseCase.execute()
            notificationsEnabled = settings.notifications.pushEnabled
        } catch {
            // Silent on load — keep optimistic default. Toggle interaction
            // will surface errors via `showError`.
        }
    }
}
