import SwiftUI

// MARK: - ProfileView

struct ProfileView: BaseViewProtocol {

    @StateObject var viewModel: ProfileViewModel

    var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            menuList
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.App.backgroundLight)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            Text(Localization.profileTitle)
                .font(.App.title2Medium)
                .tracking(CGFloat.Tracking.title2)
                .foregroundStyle(Color.App.text)

            Spacer()

            avatar
        }
        .padding(.horizontal, CGFloat.Spacing.md)
        .padding(.top, CGFloat.Spacing.lg)
        .padding(.bottom, CGFloat.Spacing.sm)
    }

    private var avatar: some View {
        CachedImage.avatar(
            url: viewModel.avatarURL,
            size: CGSize(width: 44, height: 44),
            iconSize: 44
        )
    }

    // MARK: - Menu list

    private var menuList: some View {
        VStack(spacing: 0) {
            ProfileMenuRowView(
                icon: "person.fill",
                title: Localization.profileMenuPersonalData,
                onTap: viewModel.didTapPersonalData
            )
            ProfileMenuRowView(
                icon: "bell.fill",
                title: Localization.profileMenuNotifications,
                trailing: .toggle(Binding(
                    get: { viewModel.notificationsEnabled },
                    set: { viewModel.setNotificationsEnabled($0) }
                ))
            )
            ProfileMenuRowView(
                icon: "heart.fill",
                title: Localization.profileMenuSavedSalons,
                onTap: viewModel.didTapSavedSalons
            )
            ProfileMenuRowView(
                icon: "gearshape.fill",
                title: Localization.profileMenuSettings,
                onTap: viewModel.didTapSettings
            )
            ProfileMenuRowView(
                icon: "globe",
                title: Localization.profileMenuLanguage,
                onTap: viewModel.didTapLanguage
            )
        }
        .padding(.horizontal, CGFloat.Spacing.md)
    }
}
