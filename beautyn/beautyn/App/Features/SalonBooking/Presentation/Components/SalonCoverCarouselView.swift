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

    @State private var scrolledID: Int?

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
            // A horizontal paging ScrollView instead of a `.page` TabView: a
            // plain SwiftUI ScrollView honors `.ignoresSafeArea`, so the cover
            // bleeds full-screen under the status bar — no UIKit content-inset
            // poking, and no lazily-created UIPageViewController that settles
            // (which is what animated the cover "panning" up on appear).
            // `.containerRelativeFrame(.horizontal)` sizes each page to the
            // carousel's width; `.clipped()` trims `.scaledToFill()` overflow.
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(imageUrls.enumerated()), id: \.offset) { offset, url in
                        LazyImage(source: url) { state in
                            if let container = state.imageContainer {
                                Image(uiImage: container.image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Color.App.beige2
                            }
                        }
                        .containerRelativeFrame(.horizontal)
                        .frame(height: height)
                        .clipped()
                        .overlay(Color.black.opacity(overlayOpacity))
                        .id(offset)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $scrolledID)
            // A single-image cover has nothing to page to — disable scrolling so
            // it can't bounce/drag.
            .scrollDisabled(imageUrls.count <= 1)
            .ignoresSafeArea(edges: .top)
            // Suppress the iOS 26 scroll-edge effect at the top: otherwise, when
            // this scroll view first appears (on data load) under the nav bar,
            // the bar fades its Liquid-Glass backdrop in over the cover.
            .scrollEdgeEffectHidden(true, for: .top)
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
                if index == (scrolledID ?? 0) {
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
        .animation(.easeInOut(duration: 0.18), value: scrolledID)
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
