//
//  StubUserService.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/5/26.
//

import Foundation

/// Stub implementation of UserServiceProtocol for development/testing
@MainActor
final class StubUserService: UserServiceProtocol {
    func fetchProfile(uid: String) async throws -> WRUserProfile? {
        // Return nil for now - will implement with Firestore in Step 2
        return nil
    }

    func upsertProfile(uid: String, profile: WRUserProfile) async throws {
        // Stub - will implement with Firestore in Step 2
        print("StubUserService: Would upsert profile for \(uid)")
    }

    func isProfileComplete(uid: String) async throws -> Bool {
        // Stub - assume incomplete for now
        return false
    }
}
