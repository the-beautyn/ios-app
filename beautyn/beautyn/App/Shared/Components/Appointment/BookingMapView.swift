import SwiftUI
import MapKit

// MARK: - BookingMapSnapshotCache
//
// Process-wide cache of rendered map snapshots, keyed by coordinate. `.task` is
// tied to view appearance and `@State` is reset whenever a lazy row is rebuilt,
// so without this the `MKMapSnapshotter` re-rendered every time the bookings
// list reappeared (the visible "reload"). The cache lets a returning view reuse
// the already-rendered image instantly. NSCache is thread-safe and self-evicts
// under memory pressure.

private enum BookingMapSnapshotCache {
    static let shared: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 50
        return cache
    }()

    static func key(for coordinate: CLLocationCoordinate2D) -> NSString {
        "\(coordinate.latitude),\(coordinate.longitude)" as NSString
    }
}

// MARK: - BookingMapView
//
// Static map preview for the upcoming-booking card. Rendered from the salon
// coordinate via `MKMapSnapshotter` (a still image rather than a live map view):
// it scrolls smoothly inside the list, renders correctly off-screen (snapshot
// tests), and matches the static-map look in Figma. Tap handling lives on the
// parent so the whole map area opens the maps-app chooser.

struct BookingMapView: View {

    let coordinate: CLLocationCoordinate2D

    @State private var snapshot: UIImage?

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        // Seed from cache so a rebuilt/returning view renders the map on its very
        // first frame — no placeholder flash, no re-snapshot.
        _snapshot = State(initialValue: BookingMapSnapshotCache.shared.object(forKey: BookingMapSnapshotCache.key(for: coordinate)))
    }

    var body: some View {
        ZStack {
            if let snapshot {
                Image(uiImage: snapshot)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.App.beige2
            }

            // Matches Figma (node 143:5241): cocoa-brown filled circle marker.
            Image(systemName: "smallcircle.filled.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.App.brown1)
                .shadow(color: .black.opacity(0.25), radius: 2)
        }
        .clipped()
        .task(id: coordinateKey) { await loadSnapshot() }
    }

    private var coordinateKey: String {
        "\(coordinate.latitude),\(coordinate.longitude)"
    }

    @MainActor
    private func loadSnapshot() async {
        // Reuse a previously rendered snapshot for this coordinate when available,
        // so reappearing in the list never re-renders the map.
        let cacheKey = BookingMapSnapshotCache.key(for: coordinate)
        if let cached = BookingMapSnapshotCache.shared.object(forKey: cacheKey) {
            snapshot = cached
            return
        }

        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 700,
            longitudinalMeters: 700
        )
        options.size = CGSize(width: 346, height: 199)

        let snapshotter = MKMapSnapshotter(options: options)
        do {
            let result = try await withCheckedThrowingContinuation { continuation in
                snapshotter.start(with: .global(qos: .userInitiated)) { snapshot, error in
                    if let snapshot {
                        continuation.resume(returning: snapshot)
                    } else {
                        continuation.resume(throwing: error ?? CancellationError())
                    }
                }
            }
            BookingMapSnapshotCache.shared.setObject(result.image, forKey: cacheKey)
            snapshot = result.image
        } catch {
            // Keep the placeholder background on failure (e.g. offline).
        }
    }
}
