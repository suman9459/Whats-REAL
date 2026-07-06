//
//  FirestoreUserService.swift
//  Whats REAL
//

import Foundation
import FirebaseFirestore

@MainActor
final class FirestoreUserService: UserServiceProtocol {
    private lazy var db = Firestore.firestore()
    private let collectionPath = "users"

    func fetchProfile(uid: String) async throws -> WRUserProfile? {
        let snapshot = try await db.collection(collectionPath).document(uid).getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: WRUserProfile.self)
    }

    func upsertProfile(uid: String, profile: WRUserProfile) async throws {
        try db.collection(collectionPath).document(uid).setData(from: profile, merge: true)
    }

    func isProfileComplete(uid: String) async throws -> Bool {
        guard let profile = try await fetchProfile(uid: uid) else {
            return false
        }
        return profile.profileComplete
    }
}
