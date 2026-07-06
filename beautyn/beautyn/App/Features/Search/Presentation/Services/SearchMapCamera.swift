import Foundation
import MapKit

// MARK: - SearchMapCamera
//
// Pure camera/region math for the search map — stateless statics,
// parameterized by the results sheet's current height fraction (the view
// model owns that state and passes it in). Directly unit-tested by
// `SearchMapCameraTests`.

enum SearchMapCamera {

    /// Approximate screen fraction covered by the header (safe area + content).
    static let headerHeightFraction = 0.13
    /// Zoom used when centering on the user (~3 km across).
    static let userLocationFocusSpan = 0.03
    /// Never zoom a tapped pin/cluster tighter than this (~500 m).
    static let minClusterZoomSpan = 0.005

    /// Camera radius per picked-place kind — mirrors the backend's base
    /// search radii, used when no server-effective radius is available.
    static func fallbackRadiusKm(for kind: SearchLocationKind) -> Double {
        switch kind {
        case .city: return 7
        case .neighborhood: return 3
        case .address: return 2
        case .poi: return 0.5
        case .unknown: return 3
        }
    }

    // MARK: - Conversions

    static func makeRegion(_ region: SearchRegion) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: region.center.latitude,
                longitude: region.center.longitude
            ),
            latitudinalMeters: region.spanMeters,
            longitudinalMeters: region.spanMeters
        )
    }

    static func makeViewport(_ region: MKCoordinateRegion) -> SearchViewport {
        SearchViewport(
            neLat: region.center.latitude + region.span.latitudeDelta / 2,
            neLng: region.center.longitude + region.span.longitudeDelta / 2,
            swLat: region.center.latitude - region.span.latitudeDelta / 2,
            swLng: region.center.longitude - region.span.longitudeDelta / 2
        )
    }

    // MARK: - Visible strip (between the header and the results sheet)

    /// Fraction of the screen height left visible between the header and the
    /// results sheet at its current snap (floored against degenerate snaps).
    static func visibleStripFraction(sheetHeightFraction: Double) -> Double {
        max(0.15, 1 - headerHeightFraction - sheetHeightFraction)
    }

    /// Screen-height fraction where the visible strip's center sits.
    static func visibleCenterFraction(sheetHeightFraction: Double) -> Double {
        (headerHeightFraction + (1 - sheetHeightFraction)) / 2
    }

    /// Region that puts `coordinate` centered in the VISIBLE strip — not in
    /// the middle of the full screen, where the sheet would cover it.
    static func focusedRegion(
        on coordinate: CLLocationCoordinate2D,
        span: MKCoordinateSpan,
        sheetHeightFraction: Double
    ) -> MKCoordinateRegion {
        let centerFraction = visibleCenterFraction(sheetHeightFraction: sheetHeightFraction)
        let latitudeOffset = (0.5 - centerFraction) * span.latitudeDelta
        let center = CLLocationCoordinate2D(
            latitude: coordinate.latitude - latitudeOffset,
            longitude: coordinate.longitude
        )
        return MKCoordinateRegion(center: center, span: span)
    }

    /// Camera region that shows the WHOLE searched area (`spanMeters` tall)
    /// inside the visible strip: zoomed out so the area fits the strip's
    /// height, and shifted south so it sits centered in the strip rather
    /// than half-hidden under the sheet.
    static func stripFittedRegion(
        center: GeoPoint,
        spanMeters: Double,
        sheetHeightFraction: Double
    ) -> MKCoordinateRegion {
        let base = makeRegion(SearchRegion(center: center, spanMeters: spanMeters))
        let cameraLatSpan = base.span.latitudeDelta
            / visibleStripFraction(sheetHeightFraction: sheetHeightFraction)
        let centerFraction = visibleCenterFraction(sheetHeightFraction: sheetHeightFraction)
        let latitudeOffset = (0.5 - centerFraction) * cameraLatSpan
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: center.latitude - latitudeOffset,
                longitude: center.longitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: cameraLatSpan,
                longitudeDelta: base.span.longitudeDelta
            )
        )
    }

    // MARK: - Zoom spans

    /// Focus zoom for a single point (pin tap, salon-from-search, locate
    /// button): zoom in to `cap`, but never zoom OUT past the user's current
    /// viewport when they're already closer.
    static func focusSpan(
        currentViewport: SearchViewport?,
        cappedAt cap: Double = minClusterZoomSpan
    ) -> MKCoordinateSpan {
        let currentLatSpan = currentViewport.map { abs($0.latSpan) } ?? cap
        let currentLngSpan = currentViewport.map { abs($0.lngSpan) } ?? cap
        return MKCoordinateSpan(
            latitudeDelta: min(currentLatSpan, cap),
            longitudeDelta: min(currentLngSpan, cap)
        )
    }

    /// Zoom into a tapped cluster's own bounding box (with padding), floored
    /// so a tight cluster never over-zooms.
    static func clusterZoomSpan(for cluster: SearchMapCluster) -> MKCoordinateSpan {
        MKCoordinateSpan(
            latitudeDelta: max((cluster.maxLat - cluster.minLat) * 1.6, minClusterZoomSpan),
            longitudeDelta: max((cluster.maxLng - cluster.minLng) * 1.6, minClusterZoomSpan)
        )
    }
}
