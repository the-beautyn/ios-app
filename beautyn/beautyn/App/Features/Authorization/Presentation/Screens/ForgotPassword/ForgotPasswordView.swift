import SwiftUI

// MARK: - ForgotPasswordView

struct ForgotPasswordView: BaseViewProtocol {

    @StateObject var viewModel: ForgotPasswordViewModel

    var contentView: some View {
        VStack(spacing: 0) {
            closeButton
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: CGFloat.Spacing.lg) {
                    titleSection
                    emailField
                    sendButton
                }
                .padding(.horizontal, CGFloat.Spacing.md)
                .padding(.top, CGFloat.Spacing.md)
                .padding(.bottom, CGFloat.Spacing.xxxl)
            }
        }
        .background(Color.App.backgroundLight)
    }

    // MARK: - Close Button

    private var closeButton: some View {
        HStack {
            Spacer()
            Button(action: viewModel.didTapClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.App.text)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, CGFloat.Spacing.md)
        .padding(.top, CGFloat.Spacing.sm)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
            Text(Localization.forgotPasswordTitle)
                .font(.App.title1Bold)
                .foregroundStyle(Color.App.text)

            Text(Localization.forgotPasswordSubtitle)
                .font(.App.body)
                .foregroundStyle(Color.App.gray2)
        }
    }

    // MARK: - Email Field

    private var emailField: some View {
        AppTextField(
            placeholder: Localization.authEmailPlaceholder,
            text: $viewModel.email,
            errorMessage: viewModel.emailError,
            keyboardType: .emailAddress,
            textContentType: .emailAddress
        )
    }

    // MARK: - Send Button

    private var sendButton: some View {
        AppButton(
            title: Localization.sendButton,
            style: .primary,
            size: .big,
            isLoading: viewModel.isButtonLoading,
            isDisabled: !viewModel.isSendEnabled,
            action: viewModel.didTapSend
        )
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    ForgotPasswordView(
        viewModel: ForgotPasswordViewModel(
            email: "test@example.com",
            transition: .init(
                didClose: {},
                didSendResetEmail: {}
            ),
            forgotPasswordUseCase: PreviewForgotPasswordUseCase()
        )
    )
}

private final class PreviewForgotPasswordUseCase: ForgotPasswordUseCase {
    func execute(email: String) async throws {}
}
#endif
