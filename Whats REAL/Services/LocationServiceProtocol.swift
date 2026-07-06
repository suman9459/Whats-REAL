//
//  LocationServiceProtocol.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/5/26.
//

import Foundation
import CoreLocation

/// Service for managing location permissions and current location
@MainActor
protocol LocationServiceProtocol: ObservableObject {
    /// Current authorization status
    var authorizationStatus: CLAuthorizationStatus { get }

    /// Current user location
    var currentLocation: CLLocation? { get }

    /// Request location permission
    func requestPermission()

    /// Start updating location if authorized
    func startUpdatingIfAuthorized()

    /// Stop updating location
    func stopUpdating()
}
