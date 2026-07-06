//
//  Geohash.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/6/26.
//

import Foundation

/// Simple geohash implementation for location-based queries
/// Encodes lat/lng coordinates into a string for efficient proximity searches
struct Geohash {
    private static let base32 = Array("0123456789bcdefghjkmnpqrstuvwxyz")
    
    /// Encode a coordinate pair into a geohash string
    /// - Parameters:
    ///   - latitude: Latitude (-90 to 90)
    ///   - longitude: Longitude (-180 to 180)
    ///   - precision: Number of characters in output (default: 9, ~5m precision)
    /// - Returns: Geohash string
    static func encode(latitude: Double, longitude: Double, precision: Int = 9) -> String {
        let lat = latitude
        let lng = longitude
        
        var geohash = ""
        var bits = 0
        var hashValue = 0
        
        var latMin: Double = -90.0
        var latMax: Double = 90.0
        var lngMin: Double = -180.0
        var lngMax: Double = 180.0
        
        var isEven = true
        
        while geohash.count < precision {
            if isEven {
                // Longitude
                let mid = (lngMin + lngMax) / 2
                if lng > mid {
                    hashValue |= (1 << (4 - bits))
                    lngMin = mid
                } else {
                    lngMax = mid
                }
            } else {
                // Latitude
                let mid = (latMin + latMax) / 2
                if lat > mid {
                    hashValue |= (1 << (4 - bits))
                    latMin = mid
                } else {
                    latMax = mid
                }
            }
            
            isEven = !isEven
            bits += 1
            
            if bits == 5 {
                geohash.append(base32[hashValue])
                bits = 0
                hashValue = 0
            }
        }
        
        return geohash
    }
    
    /// Returns the geohash prefix at the given precision for use in Firestore proximity queries.
    /// Precision 4 covers roughly a 40km × 20km cell — large enough to capture a 10km radius
    /// from the center while keeping the Firestore result set manageable.
    static func prefix(latitude: Double, longitude: Double, precision: Int = 4) -> String {
        String(encode(latitude: latitude, longitude: longitude, precision: precision).prefix(precision))
    }

    /// Decode a geohash string back to approximate coordinates
    /// - Parameter geohash: Geohash string
    /// - Returns: Tuple of (latitude, longitude) at center of geohash box
    static func decode(_ geohash: String) -> (latitude: Double, longitude: Double)? {
        guard !geohash.isEmpty else { return nil }
        
        var latMin: Double = -90.0
        var latMax: Double = 90.0
        var lngMin: Double = -180.0
        var lngMax: Double = 180.0
        
        var isEven = true
        
        for char in geohash.lowercased() {
            guard let index = base32.firstIndex(of: char) else {
                return nil
            }
            
            let hashValue = base32.distance(from: base32.startIndex, to: index)
            
            for i in stride(from: 4, through: 0, by: -1) {
                let bit = (hashValue >> i) & 1
                
                if isEven {
                    // Longitude
                    let mid = (lngMin + lngMax) / 2
                    if bit == 1 {
                        lngMin = mid
                    } else {
                        lngMax = mid
                    }
                } else {
                    // Latitude
                    let mid = (latMin + latMax) / 2
                    if bit == 1 {
                        latMin = mid
                    } else {
                        latMax = mid
                    }
                }
                
                isEven = !isEven
            }
        }
        
        let lat = (latMin + latMax) / 2
        let lng = (lngMin + lngMax) / 2
        
        return (lat, lng)
    }
}
