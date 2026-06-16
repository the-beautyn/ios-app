import SwiftUI
import WebKit

// MARK: - WebBookingWebView
//
// A `WKWebView` wrapper that drives a provider's web booking widget per a
// `WebBookingConfiguration`: it autofills the form page with the user's
// `WebBookingAutofill` details and, on the completion page, scrapes the booking
// id and reports it once via `onCompleted`.
//
// Unlike the display-only `WebView` used by `WebPageView`, this needs a
// `WKWebView` for JavaScript injection, navigation observation (the widgets are
// client-rendered SPAs), and `.url` KVO. Provider-agnostic — all specifics live
// in the configuration.

struct WebBookingWebView: UIViewRepresentable {

    let url: URL
    let configuration: WebBookingConfiguration
    let autofill: WebBookingAutofill
    let onCompleted: (WebBookingResult) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(configuration: configuration, autofill: autofill, onCompleted: onCompleted)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = context.coordinator
        context.coordinator.attach(webView: webView)
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Keep the coordinator's callback fresh across SwiftUI re-renders.
        context.coordinator.onCompleted = onCompleted
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, WKNavigationDelegate {

        private let configuration: WebBookingConfiguration
        private let autofill: WebBookingAutofill
        var onCompleted: (WebBookingResult) -> Void

        private weak var webView: WKWebView?
        private var urlObservation: NSKeyValueObservation?

        // Guards so the KVO + didFinish callbacks don't restart the retry loops
        // for a page we're already handling, and so completion fires once.
        private var autofilledURL: URL?
        private var scrapedURL: URL?
        private var didComplete = false

        init(
            configuration: WebBookingConfiguration,
            autofill: WebBookingAutofill,
            onCompleted: @escaping (WebBookingResult) -> Void
        ) {
            self.configuration = configuration
            self.autofill = autofill
            self.onCompleted = onCompleted
        }

        deinit {
            urlObservation?.invalidate()
        }

        func attach(webView: WKWebView) {
            self.webView = webView
            urlObservation?.invalidate()
            urlObservation = webView.observe(\.url, options: [.new]) { [weak self] _, change in
                self?.handle(url: change.newValue ?? nil)
            }
        }

        // MARK: WKNavigationDelegate

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            handle(url: navigationAction.request.url)
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            handle(url: webView.url)
        }

        // MARK: - Routing

        private func handle(url: URL?) {
            DispatchQueue.main.async { [weak self] in
                guard let self, let url else { return }
                let path = url.path.lowercased()

                if path.hasSuffix(self.configuration.autofillPathSuffix.lowercased()),
                   self.autofilledURL != url {
                    self.autofilledURL = url
                    self.autofillForm()
                }

                if path.hasSuffix(self.configuration.completionPathSuffix.lowercased()),
                   self.scrapedURL != url, !self.didComplete {
                    self.scrapedURL = url
                    self.fetchBookingId(currentURL: url, retriesRemaining: 15)
                }
            }
        }

        // MARK: - Autofill

        private func autofillForm() {
            for field in configuration.fields {
                let value = autofill.value(for: field.kind)
                guard !value.isEmpty else { continue }
                fill(field: field, value: value, retriesRemaining: 12)
            }
        }

        private func fill(field: WebBookingField, value: String, retriesRemaining: Int) {
            guard let webView else { return }
            let escapedValue = value
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
            let keywords = field.keywords.map { $0.lowercased() }
            let preferredTypes = field.preferredInputTypes.map { $0.lowercased() }
            let keywordsJSON = jsonArrayString(from: keywords)
            let preferredTypesJSON = jsonArrayString(from: preferredTypes)
            let js = """
            (function() {
                const targetValue = "\(escapedValue)";
                const keywords = \(keywordsJSON);
                const preferredTypes = \(preferredTypesJSON);

                const normalize = (text) => (text || "")
                    .toLowerCase()
                    .replace(/[’`´]/g, "'")
                    .trim();

                const matchesKeyword = (text) => {
                    if (!text) { return false; }
                    const normalized = normalize(text);
                    return keywords.some((keyword) => normalized.includes(keyword));
                };

                const matchesPreferredType = (el) => {
                    if (!preferredTypes.length) { return true; }
                    const type = (el.getAttribute('type') || '').toLowerCase();
                    return preferredTypes.includes(type);
                };

                const markValue = (el) => {
                    el.focus();
                    el.value = targetValue;
                    el.dispatchEvent(new Event('input', { bubbles: true }));
                    el.dispatchEvent(new Event('change', { bubbles: true }));
                    el.dispatchEvent(new Event('blur', { bubbles: true }));
                    return true;
                };

                const inputs = Array.from(document.querySelectorAll('input, textarea')).filter(matchesPreferredType);
                const directMatch = inputs.find((el) => {
                    return matchesKeyword(el.getAttribute('placeholder'))
                        || matchesKeyword(el.getAttribute('aria-label'))
                        || matchesKeyword(el.getAttribute('name'))
                        || matchesKeyword(el.id)
                        || matchesKeyword(el.getAttribute('data-name'))
                        || matchesKeyword(el.getAttribute('data-field'));
                });
                if (directMatch) {
                    return markValue(directMatch);
                }

                const labelMatch = Array.from(document.querySelectorAll('label')).find((label) => {
                    return matchesKeyword(label.textContent);
                });
                if (labelMatch) {
                    const targetId = labelMatch.getAttribute('for');
                    const labeledField = targetId
                        ? document.getElementById(targetId)
                        : labelMatch.querySelector('input, textarea');
                    if (labeledField && matchesPreferredType(labeledField)) {
                        return markValue(labeledField);
                    }
                }

                return false;
            })();
            """
            webView.evaluateJavaScript(js) { [weak self] result, _ in
                let didFill = (result as? Bool) ?? false
                if didFill {
                    self?.dismissKeyboard()
                } else if retriesRemaining > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self?.fill(field: field, value: value, retriesRemaining: retriesRemaining - 1)
                    }
                }
            }
        }

        // MARK: - Completion scraping

        private func fetchBookingId(currentURL: URL, retriesRemaining: Int) {
            guard let webView, !didComplete else { return }
            let patternsJSON = jsonArrayString(from: configuration.bookingIdRegexes)
            let js = """
            (function() {
                const patterns = \(patternsJSON);
                const regexes = patterns.map((p) => {
                    try { return new RegExp(p, 'i'); } catch (e) { return null; }
                }).filter(Boolean);

                const collect = (source) => {
                    if (!source) { return null; }
                    for (const re of regexes) {
                        const match = source.match(re);
                        if (match && match[1]) { return match[1]; }
                    }
                    return null;
                };

                const html = document.documentElement.outerHTML;
                const text = document.body ? document.body.innerText : '';
                const state = (window.__NUXT__ && window.__NUXT__.state) || null;
                const stateString = state ? JSON.stringify(state) : '';

                return collect(html) || collect(text) || collect(stateString) || '';
            })();
            """
            webView.evaluateJavaScript(js) { [weak self] result, _ in
                guard let self, !self.didComplete else { return }
                if let bookingId = result as? String, !bookingId.isEmpty {
                    self.didComplete = true
                    self.onCompleted(WebBookingResult(bookingId: bookingId, url: currentURL))
                } else if retriesRemaining > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.fetchBookingId(currentURL: currentURL, retriesRemaining: retriesRemaining - 1)
                    }
                }
            }
        }

        // MARK: - Helpers

        private func dismissKeyboard() {
            DispatchQueue.main.async { [weak self] in
                self?.webView?.endEditing(true)
            }
        }

        private func jsonArrayString(from array: [String]) -> String {
            guard
                let data = try? JSONSerialization.data(withJSONObject: array),
                let json = String(data: data, encoding: .utf8)
            else {
                return "[]"
            }
            return json
        }
    }
}
