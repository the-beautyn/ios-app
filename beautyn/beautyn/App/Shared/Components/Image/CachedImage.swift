import SwiftUI
import NukeUI
import Nuke

// MARK: - CachedImage

struct CachedImage<ClipShape: Shape>: View {

    let url: URL?
    let size: CGSize
    let clipShape: ClipShape
    var placeholder: AnyView

    @SwiftUI.Environment(\.displayScale) private var displayScale

    init(
        url: URL?,
        size: CGSize,
        clipShape: ClipShape,
        placeholder: AnyView = AnyView(Color.App.beige2)
    ) {
        self.url = url
        self.size = size
        self.clipShape = clipShape
        self.placeholder = placeholder
    }

    var body: some View {
        if url != nil {
            LazyImage(source: url) { state in
                if let container = state.imageContainer {
                    SwiftUI.Image(uiImage: container.image)
                        .resizable()
                        .scaledToFill()
                } else {
                    placeholder
                }
            }
            .processors(resizeProcessors)
            .frame(width: size.width, height: size.height)
            .clipped()
            .clipShape(clipShape)
        } else {
            placeholder
                .frame(width: size.width, height: size.height)
                .clipShape(clipShape)
        }
    }

    // MARK: - Private

    private var resizeProcessors: [ImageProcessing] {
        [
            ImageProcessors.Resize(
                size: CGSize(width: size.width * displayScale, height: size.height * displayScale),
                contentMode: .aspectFill
            )
        ]
    }
}

// MARK: - Convenience

extension CachedImage where ClipShape == Circle {

    static func avatar(
        url: URL?,
        size: CGSize,
        iconSize: CGFloat? = nil
    ) -> CachedImage<Circle> {
        // Default the icon to ~50% of the avatar size so it sits centered
        // inside the circle clip regardless of the avatar diameter — small
        // 40pt avatars (specialist rows) and larger profile avatars both
        // look correct.
        let effectiveIconSize = iconSize ?? (size.width * 0.5)
        return CachedImage<Circle>(
            url: url,
            size: size,
            clipShape: Circle(),
            placeholder: AnyView(
                Color.App.beige2
                    .overlay(
                        SwiftUI.Image(systemName: "person.fill")
                            .font(.system(size: effectiveIconSize))
                            .foregroundStyle(Color.App.gray2)
                    )
            )
        )
    }
}
