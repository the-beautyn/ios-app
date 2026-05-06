import Foundation
import SwiftUI

enum BeautynAlertVariant {
    case error
    case warning
    case success

    var iconAssetName: String {
        switch self {
        case .error:   return "error_alert_ic"
        case .warning: return "warning_alert_ic"
        case .success: return "success_alert_ic"
        }
    }

    var tint: Color {
        switch self {
        case .error:   return .App.error
        case .warning: return .App.warning
        case .success: return .App.success
        }
    }
}

struct BeautynAlertContent: Identifiable, Equatable {
    let id = UUID()
    let variant: BeautynAlertVariant
    let title: String?
    let message: AttributedString

    static func == (lhs: BeautynAlertContent, rhs: BeautynAlertContent) -> Bool {
        lhs.id == rhs.id
    }
}

extension BeautynAlertContent {
    static func error(_ message: String) -> BeautynAlertContent {
        BeautynAlertContent(variant: .error, title: nil, message: AttributedString(message))
    }

    static func warning(_ message: String) -> BeautynAlertContent {
        BeautynAlertContent(variant: .warning, title: nil, message: parseMarkdown(message))
    }

    static func warning(_ message: AttributedString) -> BeautynAlertContent {
        BeautynAlertContent(variant: .warning, title: nil, message: message)
    }

    static func success(_ message: String) -> BeautynAlertContent {
        BeautynAlertContent(variant: .success, title: nil, message: AttributedString(message))
    }

    static func success(title: String, message: String) -> BeautynAlertContent {
        BeautynAlertContent(variant: .success, title: title, message: AttributedString(message))
    }

    private static func parseMarkdown(_ string: String) -> AttributedString {
        (try? AttributedString(markdown: string)) ?? AttributedString(string)
    }
}
