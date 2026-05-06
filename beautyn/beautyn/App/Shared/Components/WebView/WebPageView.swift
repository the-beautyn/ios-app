import SwiftUI
import WebKit

struct WebPageView: View {

    let presentation: WebPagePresentation

    @SwiftUI.Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            WebView(url: presentation.url)
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
