import Foundation

@MainActor
final class AlertRelay {
    static let shared = AlertRelay()

    private var pending: BeautynAlertContent?

    private init() {}

    func enqueue(_ alert: BeautynAlertContent) {
        pending = alert
    }

    func consume() -> BeautynAlertContent? {
        defer { pending = nil }
        return pending
    }
}
