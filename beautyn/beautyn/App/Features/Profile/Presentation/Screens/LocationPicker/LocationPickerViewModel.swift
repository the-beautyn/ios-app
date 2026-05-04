import Foundation
import Combine
import MapKit
import CoreLocation

// MARK: - LocationPickerViewModel
//
// Backed by `MKLocalSearchCompleter` for autocomplete and `CLLocationManager`
// + `MKReverseGeocodingRequest` for the "Моя геолокація" row. The picker
// itself is a self-contained sheet — it returns the chosen city string via
// `Transition.didSelectCity`, or nothing on dismiss.

@MainActor
final class LocationPickerViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        let didSelectCity: (String) -> Void
        let didDismiss: () -> Void
    }

    // MARK: - Suggestion (Presentation Entity)

    struct Suggestion: Identifiable, Equatable {
        let id = UUID()
        let title: String
        let subtitle: String
    }

    // MARK: - Published

    @Published var query: String = "" {
        didSet {
            completer.queryFragment = query
            if query.isEmpty { suggestions = [] }
        }
    }
    @Published private(set) var suggestions: [Suggestion] = []
    @Published private(set) var isLocating: Bool = false
    @Published var permissionDenied: Bool = false

    // MARK: - Dependencies

    private let transition: Transition
    private let completer: MKLocalSearchCompleter
    private let locationManager = CLLocationManager()
    private let completerDelegate: CompleterDelegate
    private let locationDelegate: LocationDelegate

    private var pendingLocationContinuation: CheckedContinuation<CLLocation, Error>?

    /// Tracks whether the next authorization-change callback should kick off a
    /// reverse-geocode. Set when the user taps "Моя геолокація" and we have
    /// to ask for permission; reset once the callback is consumed. Without
    /// this gate, iOS fires `locationManagerDidChangeAuthorization` once when
    /// the delegate is assigned — and if permission is already granted, that
    /// would auto-resolve the city and dismiss the sheet on open.
    private var isAwaitingAuthorization: Bool = false

    // MARK: - Init

    init(transition: Transition) {
        self.transition = transition
        self.completer = MKLocalSearchCompleter()
        self.completerDelegate = CompleterDelegate()
        self.locationDelegate = LocationDelegate()
        super.init()

        completer.delegate = completerDelegate
        completer.resultTypes = [.address, .pointOfInterest]
        completerDelegate.onUpdate = { [weak self] results in
            self?.applyResults(results)
        }

        locationManager.delegate = locationDelegate
        locationDelegate.onAuthorizationChange = { [weak self] status in
            self?.handleAuthorizationChange(status)
        }
        locationDelegate.onLocation = { [weak self] location in
            self?.pendingLocationContinuation?.resume(returning: location)
            self?.pendingLocationContinuation = nil
        }
        locationDelegate.onError = { [weak self] error in
            self?.pendingLocationContinuation?.resume(throwing: error)
            self?.pendingLocationContinuation = nil
        }
    }

    // MARK: - Intents

    func didTapDismiss() {
        transition.didDismiss()
    }

    func didTapSuggestion(_ suggestion: Suggestion) {
        let city = suggestion.title.split(separator: ",").first.map(String.init)?
            .trimmingCharacters(in: .whitespaces)
        let result = (city?.isEmpty == false) ? city! : suggestion.title
        transition.didSelectCity(result)
    }

    func didTapMyGeolocation() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            isAwaitingAuthorization = true
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            permissionDenied = true
        case .authorizedWhenInUse, .authorizedAlways:
            Task { await resolveCurrentCity() }
        @unknown default:
            break
        }
    }

    // MARK: - Private

    private func applyResults(_ results: [MKLocalSearchCompletion]) {
        // The completer can fire late updates after the field is cleared;
        // an empty query owns an empty list, so ignore those.
        guard !query.isEmpty else { return }
        suggestions = results.map {
            Suggestion(title: $0.title, subtitle: $0.subtitle)
        }
    }

    private func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        guard isAwaitingAuthorization else { return }
        isAwaitingAuthorization = false
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            Task { await resolveCurrentCity() }
        case .denied, .restricted:
            permissionDenied = true
        default:
            break
        }
    }

    private func resolveCurrentCity() async {
        isLocating = true
        defer { isLocating = false }
        do {
            let location: CLLocation = try await withCheckedThrowingContinuation { cont in
                pendingLocationContinuation = cont
                locationManager.requestLocation()
            }
            guard let request = MKReverseGeocodingRequest(location: location) else { return }
            let mapItems = try await request.mapItems
            if let city = mapItems.first?.addressRepresentations?.cityWithContext, !city.isEmpty {
                transition.didSelectCity(city)
            }
        } catch {
            showError(error)
        }
    }
}

// MARK: - CompleterDelegate

private final class CompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
    var onUpdate: (([MKLocalSearchCompletion]) -> Void)?

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        onUpdate?(completer.results)
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        onUpdate?([])
    }
}

// MARK: - LocationDelegate

private final class LocationDelegate: NSObject, CLLocationManagerDelegate {
    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?
    var onLocation: ((CLLocation) -> Void)?
    var onError: ((Error) -> Void)?

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuthorizationChange?(manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let last = locations.last {
            onLocation?(last)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onError?(error)
    }
}
