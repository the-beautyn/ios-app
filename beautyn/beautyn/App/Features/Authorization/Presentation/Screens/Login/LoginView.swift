import SwiftUI

// MARK: - LoginView

struct LoginView: BaseViewProtocol {

    @StateObject var viewModel: LoginViewModel
    @FocusState private var isPasswordFocused: Bool

    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: CGFloat.Spacing.lg) {
                VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
                    titleSection
                    passwordField
                    forgotPasswordButton
                }
                continueButton
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.xxxl)
        }
        .background(Color.App.backgroundLight)
        .onAppear { isPasswordFocused = true }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
            Text(Localization.loginTitle)
                .font(.App.title1Medium)
                .foregroundStyle(Color.App.text)

            subtitleText
                .foregroundStyle(Color.App.brown1)
        }
    }

    private var subtitleText: Text {
        let prefix = Text(Localization.loginSubtitle("")).font(.App.callout)
        let email = Text(viewModel.email).font(.App.calloutMedium)
        return Text("\(prefix)\(email)")
    }

    // MARK: - Password Field

    private var passwordField: some View {
        AppSecureField(
            placeholder: Localization.loginPasswordPlaceholder,
            text: $viewModel.password,
            errorMessage: viewModel.passwordError,
            externalFocus: $isPasswordFocused
        )
    }

    // MARK: - Forgot Password

    private var forgotPasswordButton: some View {
        Button(action: viewModel.didTapForgotPassword) {
            Text(Localization.forgotPasswordLink)
                .font(.App.subheadline)
                .foregroundStyle(Color.App.brown1)
        }
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        AppButton(
            title: Localization.continueButton,
            style: .primary,
            size: .big,
            isLoading: viewModel.isButtonLoading,
            isDisabled: !viewModel.isContinueEnabled,
            action: viewModel.didTapContinue
        )
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    LoginView(
        viewModel: LoginViewModel(
            email: "test@example.com",
            transition: .init(
                didClose: {},
                didLogin: {},
                didTapForgotPassword: { _ in },
                didRequestPhoneVerification: {}
            ),
            loginUseCase: PreviewLoginUseCase()
        )
    )
}

private final class PreviewLoginUseCase: LoginUseCase {
    func execute(email: String, password: String) async throws -> AuthSession {
        AuthSession(accessToken: "", refreshToken: "", expiresIn: 3600, phoneVerificationRequired: false)
    }
}
#endif
