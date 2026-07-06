//
//  StubLocationService.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/5/26.
//

import Foundation
import CoreLocation

/// Stub implementation of LocationServiceProtocol for development/testing
@MainActor
final class StubLocationService: NSObject, LocationServiceProtocol, ObservableObject {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var currentLocation: CLLocation?

    func requestPermission() {
        print("StubLocationService: Would request permission")
        authorizationStatus = .authorizedWhenInUse
    }

    func startUpdatingIfAuthorized() {
        print("StubLocationService: Would start updating location")
        // Mock location: San Francisco
        currentLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
    }

    func stopUpdating() {
        print("StubLocationService: Would stop updating location")
    }
}
