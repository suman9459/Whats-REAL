//
//  WRPlace.swift
//  Whats REAL
//

import Foundation
import MapKit

struct WRPlace: Codable, Identifiable {
    let id: String
    let name: String
    let address: String
    let lat: Double
    let lng: Double
}

extension WRPlace {
    init(from mapItem: MKMapItem) {
        let coord = mapItem.placemark.coordinate
        self.init(
            id: "\(coord.latitude)_\(coord.longitude)",
            name: mapItem.name ?? mapItem.placemark.locality ?? "Unknown Place",
            address: mapItem.placemark.formattedAddress,
            lat: coord.latitude,
            lng: coord.longitude
        )
    }
}

extension CLPlacemark {
    var formattedAddress: String {
        [subThoroughfare, thoroughfare, locality, administrativeArea]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
