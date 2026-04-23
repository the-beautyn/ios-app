import SwiftUI

// MARK: - CheckEmailSentView

struct CheckEmailSentView: BaseViewProtocol {

    @StateObject var viewModel: CheckEmailSentViewModel

    var contentView: some View {
        ScrollView(showsIndicators: false) {
            titleSection
                .padding(.horizontal, CGFloat.Spacing.md)
                .padding(.top, CGFloat.Spacing.md)
                .padding(.bottom, CGFloat.Spacing.xxxl)
        }
        .background(Color.App.backgroundLight)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm + 4) {
            Text(Localization.checkEmailSentTitle)
                .font(.App.title1Medium)
                .foregroundStyle(Color.App.text)

            Text(Localization.checkEmailSentSubtitle(viewModel.email))
                .font(.App.callout)
                .foregroundStyle(Color.App.brown1)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    CheckEmailSentView(
        viewModel: CheckEmailSentViewModel(
            email: "anna@example.com",
            transition: .init(didClose: {})
        )
    )
}
#endif
