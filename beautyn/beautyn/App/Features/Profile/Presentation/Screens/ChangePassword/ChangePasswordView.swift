import SwiftUI

// MARK: - ChangePasswordView
//
// Matches Figma nodes 1:8679 (empty) and 1:8708 (filled). Three labelled
// secure fields with eye-toggle. Toolbar: leading back button (system),
// trailing checkmark bound to `viewModel.didTapSubmit()`.

struct ChangePasswordView: BaseViewProtocol {

    @StateObject var viewModel: ChangePasswordViewModel

    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: CGFloat.Spacing.sm + 4) {
                oldPasswordField
                newPasswordField
                confirmPasswordField
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.xxxl)
        }
        .background(Color.App.backgroundLight)
    }

    // MARK: - Fields

    private var oldPasswordField: some View {
        LabeledField(label: Localization.profileOldPasswordLabel) {
            AppSecureField(
                placeholder: Localization.profileOldPasswordLabel,
                text: $viewModel.oldPassword,
                errorMessage: viewModel.oldPasswordError
            )
        }
    }

    private var newPasswordField: some View {
        LabeledField(label: Localization.profileNewPasswordLabel) {
            AppSecureField(
                placeholder: Localization.profileNewPasswordLabel,
                text: $viewModel.newPassword,
                errorMessage: viewModel.newPasswordError
            )
        }
    }

    private var confirmPasswordField: some View {
        LabeledField(label: Localization.profileConfirmPasswordLabel) {
            AppSecureField(
                placeholder: Localization.profileConfirmPasswordLabel,
                text: $viewModel.confirmPassword,
                errorMessage: viewModel.confirmPasswordError
            )
        }
    }
}
