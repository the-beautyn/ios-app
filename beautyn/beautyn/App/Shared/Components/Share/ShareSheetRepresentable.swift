import SwiftUI
import UIKit

// MARK: - ShareSheetRepresentable
//
// Thin wrapper around `UIActivityViewController` so any SwiftUI screen can
// present the system share sheet (e.g. via `.sheet`). Used by SalonProfile and
// BookingDetails to share a salon link.

struct ShareSheetRepresentable: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}
