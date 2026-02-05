//
//  AppUser.swift
//  Whats_REALApp
//
//  Created by Whats_REALApp Team on 2026-02-05.
//

import Foundation

public struct AppUser: Sendable, Equatable, Identifiable, Codable {
    public let id: String
    public let email: String
    public let profileComplete: Bool

    public init(id: String, email: String, profileComplete: Bool = false) {
        self.id = id
        self.email = email
        self.profileComplete = profileComplete
    }
}
