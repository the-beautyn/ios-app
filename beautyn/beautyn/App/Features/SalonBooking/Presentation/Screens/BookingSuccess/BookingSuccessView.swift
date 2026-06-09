import SwiftUI

// MARK: - BookingSuccessView
//
// Matches Figma "Вас успішно записано" (node 143:3199): the brand logo centered
// over a fog-grey background with the success title beneath it.

struct BookingSuccessView: BaseViewProtocol {

    @StateObject var viewModel: BookingSuccessViewModel

    var contentView: some View {
        ZStack {
            VStack(spacing: 11) {
                Image("booking_success_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)

                Text(Localization.bookingSuccessTitle)
                    .font(.App.largeTitleBold)
                    .foregroundStyle(Color.App.brown1)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            // Figma seats the block just above the vertical center (node 143:3199).
            .offset(y: -48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.App.fogGrey)
        .ignoresSafeArea()
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    BookingSuccessView(viewModel: BookingSuccessViewModel(transition: .init(didFinish: {})))
}
#endif
