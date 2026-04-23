import SwiftUI

// MARK: - SetNewPasswordView

struct SetNewPasswordView: BaseViewProtocol {

    @StateObject var viewModel: SetNewPasswordViewModel
    @FocusState private var isNewPasswordFocused: Bool
    @FocusState private var isConfirmPasswordFocused: Bool

    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
                emailBlock
                newPasswordBlock
                confirmPasswordBlock

                if viewModel.isExpiredLinkVisible {
                    expiredLinkSection
                }
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.lg - 4)
            .padding(.bottom, CGFloat.Spacing.xxxl)
        }
        .background(Color.App.backgroundLight)
        .onAppear { isNewPasswordFocused = true }
    }

    // MARK: - Email (disabled)

    private var emailBlock: some View {
        LabeledField(label: Localization.setNewPasswordEmailLabel) {
            AppTextField(
                placeholder: Localization.authEmailPlaceholder,
                text: .constant(viewModel.email),
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                isDisabled: true
            )
        }
    }

    // MARK: - New Password

    private var newPasswordBlock: some View {
        LabeledField(label: Localization.setNewPasswordNewLabel) {
            AppSecureField(
                placeholder: Localization.loginPasswordPlaceholder,
                text: $viewModel.newPassword,
                errorMessage: viewModel.newPasswordError,
                externalFocus: $isNewPasswordFocused,
                onSubmit: { isConfirmPasswordFocused = true }
            )
        }
    }

    // MARK: - Confirm Password

    private var confirmPasswordBlock: some View {
        LabeledField(label: Localization.setNewPasswordConfirmLabel) {
            AppSecureField(
                placeholder: Localization.loginPasswordPlaceholder,
                text: $viewModel.confirmPassword,
                errorMessage: viewModel.confirmError,
                externalFocus: $isConfirmPasswordFocused,
                onSubmit: viewModel.didTapSubmit
            )
        }
    }

    // MARK: - Expired Link

    private var expiredLinkSection: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
            if let message = viewModel.expiredLinkError {
                Text(message)
                    .font(.App.footnote)
                    .foregroundStyle(Color.App.red)
            }
            if let confirmation = viewModel.newLinkSentMessage {
                Text(confirmation)
                    .font(.App.calloutMedium)
                    .foregroundStyle(Color.App.brown1)
            } else if viewModel.isRequestingNewLink {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Button(action: viewModel.didTapRequestNewLink) {
                    Text(Localization.setNewPasswordRequestNewLink)
                        .font(.App.calloutMedium)
                        .foregroundStyle(Color.App.brown1)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, CGFloat.Spacing.xs)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    SetNewPasswordView(
        viewModel: SetNewPasswordViewModel(
            email: "helga.altuhova@gmail.com",
            code: "preview-code",
            transition: .init(didResetPassword: {}),
            resetPasswordUseCase: PreviewResetPasswordUseCase(),
            forgotPasswordUseCase: PreviewForgotPasswordUseCase()
        )
    )
}

private final class PreviewResetPasswordUseCase: ResetPasswordUseCase {
    func execute(token: String, newPassword: String) async throws {}
}

private final class PreviewForgotPasswordUseCase: ForgotPasswordUseCase {
    func execute(email: String) async throws {}
}
#endif
