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
                    NukeUI.Image(container)
                        .resizingMode(.aspectFill)
                } else {
                    placeholder
                }
            }
            .processors(resizeProcessors)
            .frame(width: size.width, height: size.height)
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
        iconSize: CGFloat = 22
    ) -> CachedImage<Circle> {
        CachedImage<Circle>(
            url: url,
            size: size,
            clipShape: Circle(),
            placeholder: AnyView(
                Color.App.beige2
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundStyle(Color.App.brown2)
                            .font(.system(size: iconSize))
                    )
            )
        )
    }
}
