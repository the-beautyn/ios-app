import SwiftUI

// MARK: - EmailCheckView

struct EmailCheckView: BaseViewProtocol {

    @StateObject var viewModel: EmailCheckViewModel
    @FocusState private var isEmailFocused: Bool

    var contentView: some View {
        scrollableContent
            .background(Color.App.backgroundLight)
            .onAppear { isEmailFocused = true }
    }

    // MARK: - Scrollable Content

    private var scrollableContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: CGFloat.Spacing.xl) {
                VStack(alignment: .leading, spacing: CGFloat.Spacing.lg) {
                    VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
                        titleSection
                        inputSection
                    }
                    continueButton
                }
                separatorView
                socialButtons
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.xxxl)
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
            Text(Localization.authTitle)
                .font(.App.title1Medium)
                .foregroundStyle(Color.App.text)

            Text(Localization.authSubtitle)
                .font(.App.callout)
                .foregroundStyle(Color.App.brown1)
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        AppTextField(
            placeholder: Localization.authEmailPlaceholder,
            text: $viewModel.email,
            errorMessage: viewModel.emailError,
            keyboardType: .emailAddress,
            textContentType: .emailAddress,
            isFocused: $isEmailFocused
        )
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

    // MARK: - Separator

    private var separatorView: some View {
        Text(Localization.or)
            .font(.App.footnote)
            .foregroundStyle(Color.App.brown1)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Social Buttons

    private var socialButtons: some View {
        VStack(spacing: CGFloat.Spacing.sm) {
            SocialAuthButtonView(provider: .apple, action: viewModel.didTapApple)
            SocialAuthButtonView(provider: .google, action: viewModel.didTapGoogle)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    EmailCheckView(
        viewModel: EmailCheckViewModel(
            transition: .init(
                didClose: {},
                didCheckEmail: { _, _ in },
                didTapAppleSignIn: {},
                didTapGoogleSignIn: {}
            ),
            checkEmailUseCase: PreviewCheckEmailUseCase()
        )
    )
}

private final class PreviewCheckEmailUseCase: CheckEmailUseCase {
    func execute(email: String) async throws -> EmailStatus {
        .notFound
    }
}
#endif
