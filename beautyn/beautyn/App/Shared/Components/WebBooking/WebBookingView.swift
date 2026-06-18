import SwiftUI

// MARK: - WebBookingView
//
// SwiftUI host for the interactive web-booking widget, presented as a sheet by
// `BaseViewProtocol` from `BaseViewModel.webBookingPresentation`. Mirrors
// `WebPageView`'s chrome (navigation title + Done) and forwards the detected
// booking to the presentation's completion handler.

struct WebBookingView: View {

    let presentation: WebBookingPresentation

    @SwiftUI.Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            WebBookingWebView(
                url: presentation.url,
                configuration: presentation.configuration,
                autofill: presentation.autofill,
                excludeBookingId: presentation.excludeBookingId,
                onCompleted: presentation.onCompleted
            )
            .ignoresSafeArea(.container, edges: .bottom)
            .navigationTitle(presentation.title ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Localization.commonDone) { dismiss() }
                }
            }
        }
    }
}
