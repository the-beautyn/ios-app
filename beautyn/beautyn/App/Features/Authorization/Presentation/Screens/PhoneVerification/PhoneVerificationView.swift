import SwiftUI

// MARK: - PhoneVerificationView

struct PhoneVerificationView: BaseViewProtocol {

    @StateObject var viewModel: PhoneVerificationViewModel
    @FocusState private var isPhoneFocused: Bool

    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: CGFloat.Spacing.xl) {
                VStack(alignment: .leading, spacing: CGFloat.Spacing.lg) {
                    VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
                        titleSection
                        phoneInput
                    }
                    sendButton
                }
                legalDisclaimer
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.xxxl)
        }
        .background(Color.App.backgroundLight)
        .onAppear { isPhoneFocused = true }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
            Text(Localization.phoneVerificationTitle)
                .font(.App.title1Medium)
                .foregroundStyle(Color.App.text)

            Text(Localization.phoneVerificationSubtitle)
                .font(.App.callout)
                .foregroundStyle(Color.App.brown1)
        }
    }

    // MARK: - Phone Input

    private var phoneInput: some View {
        AppPhoneField(
            countryCode: viewModel.countryCode,
            text: $viewModel.phoneNumber,
            errorMessage: viewModel.phoneError,
            isFocused: $isPhoneFocused
        )
    }

    // MARK: - Send Button

    private var sendButton: some View {
        AppButton(
            title: Localization.phoneVerificationSendCode,
            style: .primary,
            size: .big,
            isLoading: viewModel.isButtonLoading,
            isDisabled: !viewModel.isSendEnabled,
            action: viewModel.didTapSendCode
        )
    }

    // MARK: - Legal Disclaimer

    private var legalDisclaimer: some View {
        Text(Localization.phoneVerificationLegal)
            .font(.App.caption2)
            .foregroundStyle(Color.App.brown1)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    PhoneVerificationView(
        viewModel: PhoneVerificationViewModel(
            transition: .init(
                didClose: {},
                didSendCode: { _ in }
            ),
            sendPhoneOTPUseCase: PreviewSendPhoneOTPUseCase()
        )
    )
}

private final class PreviewSendPhoneOTPUseCase: SendPhoneOTPUseCase {
    func execute(phone: String) async throws {}
}
#endif
