import Foundation
import Combine

@MainActor
final class ProfileSettingsViewModel: BaseViewModel {

    struct Transition {
        let didTapChangePassword: () -> Void
        let didLogout: () -> Void
        let didDeleteAccount: () -> Void
    }

    @Published var isLogoutAlertPresented: Bool = false
    @Published var isDeleteAccountAlertPresented: Bool = false

    private let transition: Transition
    private let logoutUseCase: any LogoutUseCase
    private let deleteAccountUseCase: any DeleteAccountUseCase

    init(
        transition: Transition,
        logoutUseCase: any LogoutUseCase,
        deleteAccountUseCase: any DeleteAccountUseCase
    ) {
        self.transition = transition
        self.logoutUseCase = logoutUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
        super.init()
    }

    func didTapTermsOfService() {
        openWebView(url: Self.placeholderURL, title: Localization.profileSettingsTermsOfService)
    }

    func didTapPrivacyPolicy() {
        openWebView(url: Self.placeholderURL, title: Localization.profileSettingsPrivacyPolicy)
    }

    func didTapChangePassword() {
        transition.didTapChangePassword()
    }

    func requestLogout() {
        isLogoutAlertPresented = true
    }

    func confirmLogout() {
        Task { await self.performLogout() }
    }

    private func performLogout() async {
        showLoader()
        await logoutUseCase.execute()
        hideLoader()
        AlertRelay.shared.enqueue(.success(Localization.profileSettingsLogoutSuccess))
        transition.didLogout()
    }

    func requestDeleteAccount() {
        isDeleteAccountAlertPresented = true
    }

    func confirmDeleteAccount() {
        Task { await self.performDeleteAccount() }
    }

    private func performDeleteAccount() async {
        showLoader()
        do {
            try await deleteAccountUseCase.execute()
            hideLoader()
            AlertRelay.shared.enqueue(.success(Localization.profileSettingsDeleteAccountSuccess))
            transition.didDeleteAccount()
        } catch {
            hideLoader()
            showError(error)
        }
    }

    private static let placeholderURL = URL(string: "https://www.google.com")!
}
