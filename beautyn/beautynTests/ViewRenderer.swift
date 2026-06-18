import SwiftUI
import UIKit
import XCTest

// MARK: - ViewRenderer
//
// Renders any SwiftUI view to a PNG file by hosting it in a real UIWindow.
// This triggers the full SwiftUI lifecycle (onAppear, .task) and handles
// ScrollView content correctly.
//
// Usage:
//   try await ViewRenderer.render(MyView(), name: "my_view")
//   → saves to /tmp/beautyn_previews/my_view.png

@MainActor
enum ViewRenderer {

    static let outputDirectory = "/tmp/beautyn_previews"
    // Prevents premature dealloc of hosted views
    private static var retainedWindows: [UIWindow] = []

    static func render<V: View>(
        _ view: V,
        name: String,
        width: CGFloat = 393,
        scale: CGFloat = 2.0,
        delay: TimeInterval = 0.5
    ) async throws {
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.backgroundColor = .white

        // Initial layout at phone width to trigger SwiftUI lifecycle
        let initialHeight: CGFloat = 852
        hostingController.view.frame = CGRect(x: 0, y: 0, width: width, height: initialHeight)

        // Attach to a window to trigger SwiftUI lifecycle. iOS 26 deprecated
        // UIWindow(frame:); create the window on the test host's active scene.
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first
        else {
            XCTFail("ViewRenderer needs an active UIWindowScene (run via the test host app)")
            return
        }
        let window = UIWindow(windowScene: windowScene)
        window.frame = CGRect(x: 0, y: 0, width: width, height: initialHeight)
        window.rootViewController = hostingController
        window.isHidden = false

        // Wait for layout + async .task to complete
        try await Task.sleep(for: .seconds(delay))

        // Calculate intrinsic content height so ScrollView content is fully visible
        let fittingSize = hostingController.sizeThatFits(in: CGSize(
            width: width,
            height: .greatestFiniteMagnitude
        ))
        let renderHeight = max(fittingSize.height, initialHeight)

        // Resize to full content height
        hostingController.view.frame = CGRect(x: 0, y: 0, width: width, height: renderHeight)
        window.frame = CGRect(x: 0, y: 0, width: width, height: renderHeight)
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()

        // Clip to width to prevent horizontal overflow from ScrollViews
        hostingController.view.clipsToBounds = true

        // Render to image
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(
            bounds: hostingController.view.bounds,
            format: format
        )
        let image = renderer.image { ctx in
            hostingController.view.layer.render(in: ctx.cgContext)
        }

        guard let data = image.pngData() else {
            XCTFail("Failed to create PNG data for \(name)")
            return
        }

        let dir = URL(filePath: outputDirectory)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let fileURL = dir.appending(path: "\(name).png")
        try data.write(to: fileURL)

        // Keep window reference alive to prevent premature ViewModel dealloc
        // crash with @StateObject + Swift Concurrency in Xcode 26
        retainedWindows.append(window)

        print("✅ Rendered \(name) (\(Int(width))×\(Int(renderHeight))pt @\(Int(scale))x) → \(fileURL.path())")
    }
}
