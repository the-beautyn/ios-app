import SwiftUI

// MARK: - PhoneCodeView

struct PhoneCodeView: BaseViewProtocol {

    @StateObject var viewModel: PhoneCodeViewModel

    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: CGFloat.Spacing.xl) {
                titleSection
                actionLinks
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.xxxl)
        }
        .background(Color.App.backgroundLight)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Localization.phoneVerificationTitle)
                .font(.App.title1Medium)
                .foregroundStyle(Color.App.black)

            subtitleText

            AppCodeField(
                code: $viewModel.code,
                length: 4,
                errorMessage: viewModel.codeError,
                autoFocus: true
            )
        }
    }

    // MARK: - Subtitle

    private var subtitleText: some View {
        let prefix = Text(Localization.phoneCodeSubtitle("")).font(.App.callout)
        let phone = Text(viewModel.phone).font(.App.calloutMedium)
        return Text("\(prefix)\(phone)")
            .foregroundStyle(Color.App.brown1)
    }

    // MARK: - Action Links

    private var actionLinks: some View {
        VStack(spacing: CGFloat.Spacing.lg) {
            Button(action: viewModel.didTapResend) {
                Text(Localization.phoneCodeResend)
                    .font(.App.subheadline)
                    .foregroundStyle(Color.App.brown1)
            }
            .buttonStyle(.plain)

            Button(action: viewModel.didTapChangeNumber) {
                Text(Localization.phoneCodeChangeNumber)
                    .font(.App.subheadline)
                    .foregroundStyle(Color.App.brown1)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    PhoneCodeView(
        viewModel: PhoneCodeViewModel(
            phone: "+380991234567",
            transition: .init(
                didClose: {},
                didVerifyPhone: {},
                didTapChangeNumber: {}
            ),
            verifyPhoneOTPUseCase: PreviewVerifyPhoneOTPUseCase(),
            sendPhoneOTPUseCase: PreviewSendPhoneOTPUseCase()
        )
    )
}

private final class PreviewVerifyPhoneOTPUseCase: VerifyPhoneOTPUseCase {
    func execute(phone: String, code: String) async throws -> Bool {
        true
    }
}

private final class PreviewSendPhoneOTPUseCase: SendPhoneOTPUseCase {
    func execute(phone: String) async throws {}
}
#endif
