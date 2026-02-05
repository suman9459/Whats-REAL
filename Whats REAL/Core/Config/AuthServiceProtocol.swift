//
//  AuthServiceProtocol.swift
//  Whats REAL
//
//  Created by Xcode Assistant on 2/5/26.
//

import Foundation

/// Protocol describing authentication service capabilities used throughout the app.
/// Keep this minimal so different implementations (e.g., Firebase, mock) can conform.
public protocol AuthServiceProtocol: Sendable {
    /// Currently signed-in user identifier, if any.
    var currentUserID: String? { get }

    /// Returns whether a user is currently authenticated.
    var isAuthenticated: Bool { get }

    /// Sign in with email and password.
    func signIn(email: String, password: String) async throws

    /// Create a new account with email and password.
    func signUp(email: String, password: String) async throws

    /// Sign out the current user.
    func signOut() async throws
}
