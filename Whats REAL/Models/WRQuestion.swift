//
//  WRQuestion.swift
//  Whats REAL
//

import Foundation

struct WRQuestion: Codable, Identifiable, Equatable {
    let id: String
    let authorId: String
    let authorName: String
    let text: String
    let photoURL: String?
    let placeId: String
    let placeName: String
    let placeAddress: String?
    let lat: Double
    let lng: Double
    let geohash: String
    let urgencyLevel: UrgencyLevel
    let createdAt: Date
    let expiresAt: Date

    enum UrgencyLevel: String, Codable {
        case info = "info"
        case happening = "happening"
        case urgent = "urgent"

        var displayName: String {
            switch self {
            case .info:      return "Need to Know"
            case .happening: return "What's Happening"
            case .urgent:    return "Urgent"
            }
        }

        var expirationHours: Double {
            switch self {
            case .info:      return 24.0
            case .happening: return 1.0
            case .urgent:    return 0.5
            }
        }
    }

    var isExpired: Bool { Date() > expiresAt }

    var timeUntilExpiry: String {
        let interval = expiresAt.timeIntervalSince(Date())
        guard interval > 0 else { return "Expired" }
        if interval < 3600 {
            return "Expires in \(Int(interval / 60))m"
        } else {
            return "Expires in \(Int(interval / 3600))h"
        }
    }
}
