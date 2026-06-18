import Foundation
import UIKit
import CoreLocation

// MARK: - MapsLauncher
//
// Opens turn-by-turn directions to a destination in Apple Maps or Google Maps.
// Prefers exact coordinates; falls back to a free-text address query when the
// destination has no coordinate (e.g. post-success bookings, since the Salon
// model carries no lat/long).

enum MapsLauncher {

    struct Destination {
        let coordinate: CLLocationCoordinate2D?
        let name: String?
        let address: String?
    }

    /// True when the Google Maps app is installed (requires `comgooglemaps` in
    /// `LSApplicationQueriesSchemes`). Drives whether the chooser is shown.
    static var isGoogleMapsInstalled: Bool {
        guard let url = URL(string: "comgooglemaps://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    static func openAppleMaps(_ destination: Destination) {
        open(appleMapsURL(destination))
    }

    static func openGoogleMaps(_ destination: Destination) {
        open(googleMapsURL(destination))
    }

    // MARK: - URL building

    private static func appleMapsURL(_ destination: Destination) -> URL? {
        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "daddr", value: destinationParameter(destination)),
            URLQueryItem(name: "dirflg", value: "d")    // driving directions
        ]
        return components?.url
    }

    private static func googleMapsURL(_ destination: Destination) -> URL? {
        // Prefer the installed app; otherwise fall back to the universal web URL.
        if isGoogleMapsInstalled {
            var components = URLComponents(string: "comgooglemaps://")
            components?.queryItems = [
                URLQueryItem(name: "daddr", value: destinationParameter(destination)),
                URLQueryItem(name: "directionsmode", value: "driving")
            ]
            return components?.url
        }
        var components = URLComponents(string: "https://www.google.com/maps/dir/")
        components?.queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "destination", value: destinationParameter(destination))
        ]
        return components?.url
    }

    /// "lat,lng" when known, else the address text (URLComponents percent-encodes it).
    private static func destinationParameter(_ destination: Destination) -> String {
        if let coordinate = destination.coordinate {
            return "\(coordinate.latitude),\(coordinate.longitude)"
        }
        return [destination.name, destination.address]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    private static func open(_ url: URL?) {
        guard let url else { return }
        UIApplication.shared.open(url)
    }
}
