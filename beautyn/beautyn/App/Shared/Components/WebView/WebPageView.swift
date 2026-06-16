import SwiftUI
import WebKit

struct WebPageView: View {

    let presentation: WebPagePresentation

    @SwiftUI.Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            WebContentView(url: presentation.url)
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

/// A `WKWebView` wrapper used instead of SwiftUI's native `WebView`.
///
/// The native iOS 26 `WebView` force-ignores the safe area (it behaves like a
/// `ScrollView`), so its content draws up under the navigation bar — and
/// `safeAreaPadding` doesn't move it (FB20169593). A `UIViewRepresentable`
/// respects the safe area like any normal view, so its frame starts below the
/// bar and the web content's top aligns to the safe area.
private struct WebContentView: UIViewRepresentable {

    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard webView.url != url else { return }
        webView.load(URLRequest(url: url))
    }
}
