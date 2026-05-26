import SwiftUI
import Nuke
import NukeUI

// MARK: - SalonCoverCarouselView
//
// Full-bleed paged image carousel used as the SalonProfile screen header.
// Renders a beige placeholder when no images are available, and a custom
// glassy indicator row matching the Figma reference (active = 18×6 white
// pill, inactive = 6pt circles with .ultraThinMaterial + 40% white tint).

struct SalonCoverCarouselView: View {

    let imageUrls: [URL]
    var height: CGFloat = 413
    var overlayOpacity: Double = 0.2
    // Pixels reserved at the bottom of the carousel where the indicator must
    // NOT sit — used when an external sheet curls over the bottom of the
    // cover, so the indicator stays visible above the sheet's rounded top.
    var indicatorBottomInset: CGFloat = 32

    @State private var selectedIndex: Int = 0

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
            if imageUrls.count > 1 {
                indicator
                    .padding(.trailing, CGFloat.Spacing.md)
                    .padding(.bottom, indicatorBottomInset)
            }
        }
        .frame(height: height)
        .clipped()
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if imageUrls.isEmpty {
            placeholder
        } else {
            // GeometryReader pins each page to the carousel's exact width via
            // an explicit `.frame(width:)`, then `.clipped()` clips any
            // overflow from `.scaledToFill()`. This avoids the `maxWidth:
            // .infinity` ambiguity where SwiftUI sometimes lets the image
            // bleed beyond the screen edges.
            //
            // TabView(.page) is backed by UIPageViewController which has its
            // own safe area handling, so .ignoresSafeArea(.top) on the
            // TabView is required for the image to extend behind the status
            // bar. LazyImage uses Nuke's default ImagePipeline — memory +
            // disk cache out of the box.
            GeometryReader { proxy in
                TabView(selection: $selectedIndex) {
                    ForEach(Array(imageUrls.enumerated()), id: \.offset) { offset, url in
                        LazyImage(source: url) { state in
                            if let container = state.imageContainer {
                                Image(uiImage: container.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: proxy.size.width, height: height)
                                    .clipped()
                            } else {
                                Color.App.beige2
                            }
                        }
                        .frame(width: proxy.size.width, height: height)
                        .overlay(Color.black.opacity(overlayOpacity))
                        .ignoresSafeArea(edges: .top)
                        .tag(offset)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea(edges: .top)
            }
        }
    }

    private var placeholder: some View {
        Color.App.beige2
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.App.gray2.opacity(0.4))
            )
    }

    // MARK: - Indicator

    private var indicator: some View {
        HStack(spacing: CGFloat.Spacing.sm) {
            ForEach(imageUrls.indices, id: \.self) { index in
                if index == selectedIndex {
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 18, height: 6)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.4))
                        .background(.ultraThinMaterial, in: Circle())
                        .frame(width: 6, height: 6)
                }
            }
        }
        .animation(.easeInOut(duration: 0.18), value: selectedIndex)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("With images") {
    SalonCoverCarouselView(
        imageUrls: [
            URL(string: "https://picsum.photos/seed/a/600/600")!,
            URL(string: "https://picsum.photos/seed/b/600/600")!,
            URL(string: "https://picsum.photos/seed/c/600/600")!,
            URL(string: "https://picsum.photos/seed/d/600/600")!
        ]
    )
}

#Preview("Empty") {
    SalonCoverCarouselView(imageUrls: [])
}
#endif
