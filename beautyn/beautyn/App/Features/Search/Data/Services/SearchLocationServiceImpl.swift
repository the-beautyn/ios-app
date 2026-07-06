import Foundation
import MapKit
import CoreLocation
import Combine

// MARK: - SearchLocationServiceImpl
//
// Platform adapter behind the Domain's `SearchLocationService` contract:
// CoreLocation for the GPS fix + permission state, MapKit for forward
// geocoding. Exposes Domain value types only.

@MainActor
final class SearchLocationServiceImpl: SearchLocationService {

    private static let locationTimeout: Duration = .seconds(5)
    private static let completionsTimeout: Duration = .seconds(2)

    private let locationManager = CLLocationManager()
    private let locationDelegate = LocationDelegate()
    private let completer = MKLocalSearchCompleter()
    private let completerDelegate = CompleterDelegate()

    private var pendingCompletionsContinuation: CheckedContinuation<[MKLocalSearchCompletion], Never>?
    /// The batch behind the last `locationCompletions(for:)` answer —
    /// `resolveLocation` maps a completion's index back into it, and only
    /// when the completion's `batchId` still matches this batch.
    private var lastCompletions: [MKLocalSearchCompletion] = []
    private var lastBatchId = UUID()

    // Concurrent callers can overlap (e.g. the locate button while the
    // initial region is still resolving) — every waiter is kept and resumed
    // together, so none is ever orphaned by a later request.
    private var pendingAuthorizationContinuations: [CheckedContinuation<CLAuthorizationStatus, Never>] = []
    private var pendingLocationContinuations: [CheckedContinuation<CLLocation, Error>] = []
    private var pendingStatusContinuations: [CheckedContinuation<CLAuthorizationStatus, Never>] = []
    /// In-flight GPS fix — concurrent `currentLocation()` calls share it
    /// instead of issuing a second `requestLocation()`.
    private var locationFetchTask: Task<CLLocation, Error>?
    // Reading `locationManager.authorizationStatus` synchronously on the main
    // thread can block on an XPC call (UI-unresponsiveness runtime warning), so
    // the status is only ever taken from `locationManagerDidChangeAuthorization`
    // — which iOS guarantees to fire once right after the delegate is assigned.
    private var latestAuthorizationStatus: CLAuthorizationStatus?
    private let permissionDenied = CurrentValueSubject<Bool, Never>(false)

    var isPermissionDeniedPublisher: AnyPublisher<Bool, Never> {
        permissionDenied.eraseToAnyPublisher()
    }

    // MARK: - Init

    init() {
        locationManager.delegate = locationDelegate
        locationDelegate.onAuthorizationChange = { [weak self] status in
            guard let self else { return }
            self.latestAuthorizationStatus = status
            self.permissionDenied.send(Self.isDenied(status))

            // A wait for the CURRENT status accepts any value, including
            // `.notDetermined` — it just wants to know where we stand.
            self.pendingStatusContinuations.forEach { $0.resume(returning: status) }
            self.pendingStatusContinuations.removeAll()

            // A wait for a permission-request ANSWER resolves only once the
            // user has actually decided.
            guard status != .notDetermined else { return }
            self.pendingAuthorizationContinuations.forEach { $0.resume(returning: status) }
            self.pendingAuthorizationContinuations.removeAll()
        }
        locationDelegate.onLocation = { [weak self] location in
            guard let self else { return }
            self.pendingLocationContinuations.forEach { $0.resume(returning: location) }
            self.pendingLocationContinuations.removeAll()
        }
        locationDelegate.onError = { [weak self] error in
            guard let self else { return }
            self.pendingLocationContinuations.forEach { $0.resume(throwing: error) }
            self.pendingLocationContinuations.removeAll()
        }

        completer.delegate = completerDelegate
        completer.resultTypes = [.address, .pointOfInterest]
        completerDelegate.onUpdate = { [weak self] results in
            self?.pendingCompletionsContinuation?.resume(returning: results)
            self?.pendingCompletionsContinuation = nil
        }
    }

    // MARK: - SearchLocationService

    func currentLocation() async -> GeoPoint? {
        var status = await currentAuthorizationStatus()
        if status == .notDetermined {
            status = await withCheckedContinuation { continuation in
                pendingAuthorizationContinuations.append(continuation)
                locationManager.requestWhenInUseAuthorization()
            }
        }
        guard status == .authorizedWhenInUse || status == .authorizedAlways,
              let location = try? await requestLocation() else { return nil }
        return GeoPoint(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }

    func geocode(_ address: String) async -> GeoPoint? {
        guard let request = MKGeocodingRequest(addressString: address),
              let item = try? await request.mapItems.first else { return nil }
        return GeoPoint(
            latitude: item.location.coordinate.latitude,
            longitude: item.location.coordinate.longitude
        )
    }

    func locationCompletions(for query: String) async -> [SearchLocationCompletion] {
        // A newer query supersedes a still-pending one — answer it with what
        // the completer knows now so its continuation never leaks.
        pendingCompletionsContinuation?.resume(returning: completer.results)
        pendingCompletionsContinuation = nil

        guard !query.isEmpty else {
            lastCompletions = []
            lastBatchId = UUID()
            return []
        }

        let completions = await withCheckedContinuation { continuation in
            pendingCompletionsContinuation = continuation
            completer.queryFragment = query

            // The completer stays silent when the fragment doesn't change its
            // results — fall back to whatever it currently holds.
            Task { [weak self] in
                try? await Task.sleep(for: Self.completionsTimeout)
                guard let self, self.pendingCompletionsContinuation != nil else { return }
                self.pendingCompletionsContinuation?.resume(returning: self.completer.results)
                self.pendingCompletionsContinuation = nil
            }
        }

        lastCompletions = completions
        lastBatchId = UUID()
        return completions.enumerated().map { index, completion in
            SearchLocationCompletion(
                id: index,
                title: completion.title,
                subtitle: completion.subtitle.isEmpty ? nil : completion.subtitle,
                batchId: lastBatchId
            )
        }
    }

    func resolveLocation(_ completion: SearchLocationCompletion) async -> SearchLocation? {
        guard completion.batchId == lastBatchId,
              lastCompletions.indices.contains(completion.id) else { return nil }
        let request = MKLocalSearch.Request(completion: lastCompletions[completion.id])
        guard let response = try? await MKLocalSearch(request: request).start(),
              let item = response.mapItems.first else { return nil }
        return SearchLocation(
            point: GeoPoint(
                latitude: item.location.coordinate.latitude,
                longitude: item.location.coordinate.longitude
            ),
            name: completion.title,
            subtitle: completion.subtitle,
            kind: Self.classify(item)
        )
    }

    /// What kind of place this is — drives the backend's search radius and
    /// the map zoom. `pointOfInterestCategory` is the only structured signal
    /// the modern MapKit API offers; city vs street address is inferred by
    /// comparing the most specific address line against the city name (there
    /// is no non-deprecated street/thoroughfare accessor).
    private static func classify(_ item: MKMapItem) -> SearchLocationKind {
        if item.pointOfInterestCategory != nil { return .poi }

        guard let city = item.addressRepresentations?.cityName, !city.isEmpty else {
            return .unknown
        }
        let specificLine = item.address?.shortAddress
            ?? item.addressRepresentations?
                .fullAddress(includingRegion: false, singleLine: false)?
                .components(separatedBy: "\n").first
        guard let specificLine, !specificLine.isEmpty else { return .unknown }

        return specificLine == city ? .city : .address
    }

    func reverseGeocodeName(_ point: GeoPoint) async -> String? {
        let location = CLLocation(latitude: point.latitude, longitude: point.longitude)
        guard let request = MKReverseGeocodingRequest(location: location),
              let item = try? await request.mapItems.first else { return nil }
        let city = item.addressRepresentations?.cityWithContext
        return city?.isEmpty == false ? city : item.name
    }

    // MARK: - Helpers

    /// The status delivered by the delegate — awaiting the initial
    /// `locationManagerDidChangeAuthorization` callback when it hasn't fired
    /// yet, with a short fallback so callers can never hang.
    private func currentAuthorizationStatus() async -> CLAuthorizationStatus {
        if let latestAuthorizationStatus {
            return latestAuthorizationStatus
        }
        return await withCheckedContinuation { continuation in
            pendingStatusContinuations.append(continuation)

            Task { [weak self] in
                try? await Task.sleep(for: .seconds(2))
                guard let self, !self.pendingStatusContinuations.isEmpty else { return }
                self.pendingStatusContinuations.forEach { $0.resume(returning: .notDetermined) }
                self.pendingStatusContinuations.removeAll()
            }
        }
    }

    private func requestLocation() async throws -> CLLocation {
        if let inFlight = locationFetchTask {
            return try await inFlight.value
        }
        let task = Task { () throws -> CLLocation in
            try await withCheckedThrowingContinuation { continuation in
                pendingLocationContinuations.append(continuation)
                locationManager.requestLocation()

                Task { [weak self] in
                    try? await Task.sleep(for: Self.locationTimeout)
                    guard let self, !self.pendingLocationContinuations.isEmpty else { return }
                    self.pendingLocationContinuations.forEach { $0.resume(throwing: CancellationError()) }
                    self.pendingLocationContinuations.removeAll()
                }
            }
        }
        locationFetchTask = task
        defer { locationFetchTask = nil }
        return try await task.value
    }

    private static func isDenied(_ status: CLAuthorizationStatus) -> Bool {
        status == .denied || status == .restricted
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
