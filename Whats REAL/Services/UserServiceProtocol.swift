//
//  UserServiceProtocol.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/5/26.
//

import Foundation

/// Service for managing user profiles in Firestore
@MainActor
protocol UserServiceProtocol {
    /// Fetch user profile from Firestore
    /// - Parameter uid: User ID
    /// - Returns: User profile if exists, nil otherwise
    func fetchProfile(uid: String) async throws -> WRUserProfile?

    /// Create or update user profile in Firestore
    /// - Parameters:
    ///   - uid: User ID
    ///   - profile: User profile data
    func upsertProfile(uid: String, profile: WRUserProfile) async throws

    /// Check if user has completed profile setup
    /// - Parameter uid: User ID
    /// - Returns: True if profile is complete
    func isProfileComplete(uid: String) async throws -> Bool
}
