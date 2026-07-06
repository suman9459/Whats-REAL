//
//  StubPlacesService.swift
//  Whats REAL
//

import Foundation

final class StubPlacesService: PlacesServiceProtocol {
    func searchPlaces(query: String) async throws -> [WRPlace] {
        try? await Task.sleep(nanoseconds: 300_000_000)
        return [
            WRPlace(id: "1", name: "Starbucks Coffee", address: "123 Main St", lat: 37.7749, lng: -122.4194),
            WRPlace(id: "2", name: "Blue Bottle Coffee", address: "456 Market St", lat: 37.7849, lng: -122.4094)
        ]
    }

    func fetchNearby() async throws -> [WRPlace] {
        try? await Task.sleep(nanoseconds: 300_000_000)
        return [
            WRPlace(id: "3", name: "Local Café", address: "789 Oak Ave", lat: 37.7649, lng: -122.4294),
            WRPlace(id: "4", name: "Corner Bakery", address: "321 Pine St", lat: 37.7749, lng: -122.4394)
        ]
    }

    func getPlaceDetails(placeId: String) async throws -> WRPlace {
        WRPlace(id: placeId, name: "Stub Place", address: "123 Stub St", lat: 37.7749, lng: -122.4194)
    }
}
