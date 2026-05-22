import SwiftUI

// MARK: - PersonalDataView

struct PersonalDataView: BaseViewProtocol {

    @StateObject var viewModel: PersonalDataViewModel

    var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                title
                header
                rows
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(Color.App.backgroundLight)
    }

    // MARK: - Sections

    private var title: some View {
        Text(Localization.profilePersonalDataTitle)
            .font(.App.title1Medium)
            .tracking(CGFloat.Tracking.title1)
            .foregroundStyle(Color.App.text)
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.lg)
    }

    private var header: some View {
        VStack(spacing: CGFloat.Spacing.sm) {
            avatar
            Text(viewModel.display.displayName)
                .font(.App.headline)
                .foregroundStyle(Color.App.text)
            AppButton.secondaryOutlined(
                title: Localization.profileEditButton,
                size: .small
            ) {
                viewModel.didTapEditProfile()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, CGFloat.Spacing.lg)
    }

    private var avatar: some View {
        ZStack(alignment: .bottomTrailing) {
            CachedImage.avatar(
                url: viewModel.display.avatarURL,
                size: CGSize(width: 100, height: 100)
            )

            Button {
                viewModel.didTapEditAvatar()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.App.white)
                        .frame(width: 26, height: 26)
                        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                    Image(.editPen)
                }
            }
            .buttonStyle(.plain)
        }
        .frame(width: 100, height: 100)
    }

    private var rows: some View {
        VStack(spacing: 0) {
            InfoRowView(label: Localization.profileDateOfBirth, value: viewModel.display.birthDate)
            InfoRowView(label: Localization.profilePhoneNumber, value: viewModel.display.phone)
            InfoRowView(label: Localization.profileEmail, value: viewModel.display.email)
            InfoRowView(label: Localization.profileCity, value: viewModel.display.city)
            InfoRowView(label: Localization.profileGender, value: viewModel.display.sex)
        }
        .padding(.horizontal, CGFloat.Spacing.md)
    }
}
