//
//  PlacesServiceProtocol.swift
//  Whats REAL
//

import Foundation

protocol PlacesServiceProtocol {
    /// Search for places matching a query, biased to the user's location when available.
    func searchPlaces(query: String) async throws -> [WRPlace]

    /// Return places near the user's current location (for the empty-state list).
    func fetchNearby() async throws -> [WRPlace]

    /// Resolve full place details by ID (not required for MKLocalSearch — may throw).
    func getPlaceDetails(placeId: String) async throws -> WRPlace
}
