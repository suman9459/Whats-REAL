//
//  WRUserProfile.swift
//  Whats REAL
//

import Foundation

struct WRUserProfile: Codable {
    let uid: String
    var displayName: String
    var profileComplete: Bool
    var createdAt: Date
    var age: Int?
    var gender: String?
    var socialStatus: String?
    var trustScore: WRTrustScore?
    var fcmToken: String?
}
