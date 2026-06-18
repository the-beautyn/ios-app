import Foundation

extension Locale {
    /// Locale matching the app's currently displayed language — the one
    /// `Localization` resolves strings to. Use it for user-facing date formatting
    /// so dates render in the same language as the rest of the UI instead of a
    /// hard-coded one.
    static var appDisplay: Locale {
        Locale(identifier: Bundle.main.preferredLocalizations.first ?? "uk")
    }
}
