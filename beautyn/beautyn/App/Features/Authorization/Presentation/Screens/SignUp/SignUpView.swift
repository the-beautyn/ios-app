import SwiftUI

// MARK: - SignUpView

struct SignUpView: BaseViewProtocol {

    @StateObject var viewModel: SignUpViewModel

    enum Field { case firstName, lastName, password }
    @FocusState private var focusedField: Field?

    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: CGFloat.Spacing.lg) {
                VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
                    titleSection
                    inputsSection
                }
                continueButton
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.xxxl)
        }
        .background(Color.App.backgroundLight)
        .onAppear { focusedField = .firstName }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
            Text(Localization.signUpTitle)
                .font(.App.title1Medium)
                .foregroundStyle(Color.App.text)

            Text(Localization.signUpSubtitle)
                .font(.App.callout)
                .foregroundStyle(Color.App.brown1)
        }
    }

    // MARK: - Inputs Section

    private var inputsSection: some View {
        VStack(spacing: CGFloat.Spacing.sm + 4) {
            AppTextField(
                placeholder: Localization.signUpFirstNamePlaceholder,
                text: $viewModel.firstName,
                errorMessage: viewModel.firstNameError,
                textContentType: .givenName,
                onSubmit: { focusedField = .lastName }
            )
            .focused($focusedField, equals: .firstName)

            AppTextField(
                placeholder: Localization.signUpLastNamePlaceholder,
                text: $viewModel.lastName,
                errorMessage: viewModel.lastNameError,
                textContentType: .familyName,
                onSubmit: { focusedField = .password }
            )
            .focused($focusedField, equals: .lastName)

            AppSecureField(
                placeholder: Localization.signUpPasswordPlaceholder,
                text: $viewModel.password,
                errorMessage: viewModel.passwordError,
                onSubmit: { viewModel.didTapContinue() }
            )
            .focused($focusedField, equals: .password)
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
    SignUpView(
        viewModel: SignUpViewModel(
            email: "test@example.com",
            transition: .init(
                didClose: {},
                didRegister: {},
                didRequestPhoneVerification: {}
            ),
            registerUseCase: PreviewRegisterUseCase()
        )
    )
}

private final class PreviewRegisterUseCase: RegisterUseCase {
    func execute(email: String, password: String, name: String, secondName: String) async throws -> AuthSession {
        AuthSession(accessToken: "", refreshToken: "", expiresIn: 0, phoneVerificationRequired: false)
    }
}
#endif
