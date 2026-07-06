//
//  MKLocalSearchPlacesService.swift
//  Whats REAL
//

import MapKit

/// Zero-cost places implementation using Apple's MapKit local search.
/// Requires no API key. Biases results to the user's current location when available.
@MainActor
final class MKLocalSearchPlacesService: PlacesServiceProtocol {
    private let locationService: any LocationServiceProtocol

    init(locationService: any LocationServiceProtocol) {
        self.locationService = locationService
    }

    func searchPlaces(query: String) async throws -> [WRPlace] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        if let location = locationService.currentLocation {
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 10_000,
                longitudinalMeters: 10_000
            )
        }
        let response = try await MKLocalSearch(request: request).start()
        return response.mapItems.prefix(20).map(WRPlace.init)
    }

    func fetchNearby() async throws -> [WRPlace] {
        guard let location = locationService.currentLocation else { return [] }
        let request = MKLocalPointsOfInterestRequest(center: location.coordinate, radius: 500)
        let response = try await MKLocalSearch(request: request).start()
        return response.mapItems.prefix(15).map(WRPlace.init)
    }

    func getPlaceDetails(placeId: String) async throws -> WRPlace {
        throw URLError(.unsupportedURL)
    }
}
