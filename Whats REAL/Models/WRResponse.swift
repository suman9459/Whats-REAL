//
//  WRResponse.swift
//  Whats REAL
//

import Foundation

struct WRResponse: Codable, Identifiable, Equatable {
    let id: String
    let responderId: String
    let responderName: String
    let type: ResponseType
    let text: String?
    let photoURL: String?
    let createdAt: Date
    let helpfulCount: Int

    enum ResponseType: String, Codable {
        case text
        case photo
        case textWithPhoto
    }

    var timeAgo: String {
        let interval = Date().timeIntervalSince(createdAt)
        switch interval {
        case ..<60:     return "Just now"
        case ..<3600:   return "\(Int(interval / 60))m ago"
        case ..<86400:  return "\(Int(interval / 3600))h ago"
        default:        return "\(Int(interval / 86400))d ago"
        }
    }
}
