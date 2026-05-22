import SwiftUI

struct ProfileSettingsView: BaseViewProtocol {

    @StateObject var viewModel: ProfileSettingsViewModel

    var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                title
                rows
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(Color.App.backgroundLight)
        .alert(
            Localization.profileSettingsLogoutAlertTitle,
            isPresented: $viewModel.isLogoutAlertPresented
        ) {
            Button(Localization.commonCancel, role: .cancel) {}
            Button(
                Localization.profileSettingsLogoutAlertConfirm,
                role: .destructive,
                action: viewModel.confirmLogout
            )
        } message: {
            Text(Localization.profileSettingsLogoutAlertMessage)
        }
        .alert(
            Localization.profileSettingsDeleteAccountAlertTitle,
            isPresented: $viewModel.isDeleteAccountAlertPresented
        ) {
            Button(Localization.commonCancel, role: .cancel) {}
            Button(
                Localization.profileSettingsDeleteAccountAlertConfirm,
                role: .destructive,
                action: viewModel.confirmDeleteAccount
            )
        } message: {
            Text(Localization.profileSettingsDeleteAccountAlertMessage)
        }
    }

    private var title: some View {
        Text(Localization.profileSettingsTitle)
            .font(.App.title1Medium)
            .tracking(CGFloat.Tracking.title1)
            .foregroundStyle(Color.App.text)
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.lg)
    }

    private var rows: some View {
        VStack(spacing: 0) {
            SettingsRowView(
                title: Localization.profileSettingsTermsOfService,
                onTap: viewModel.didTapTermsOfService
            )
            SettingsRowView(
                title: Localization.profileSettingsPrivacyPolicy,
                onTap: viewModel.didTapPrivacyPolicy
            )
            SettingsRowView(
                title: Localization.profileSettingsChangePassword,
                onTap: viewModel.didTapChangePassword
            )
            SettingsRowView(
                title: Localization.profileSettingsLogout,
                onTap: viewModel.requestLogout
            )
            SettingsRowView(
                title: Localization.profileSettingsDeleteAccount,
                isDestructive: true,
                onTap: viewModel.requestDeleteAccount
            )
        }
    }
}
