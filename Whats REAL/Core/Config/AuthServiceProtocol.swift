//
//  AuthServiceProtocol.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 7/3/24.
//

import Foundation
import AuthenticationServices

/// Protocol describing authentication service capabilities used throughout the app.
/// Keep this minimal so different implementations (e.g., Firebase, mock) can conform.
public protocol AuthServiceProtocol: Sendable {
    /// Currently signed-in user identifier, if any.
    var currentUserID: String? { get }

    /// Currently signed-in email, if available.
    var currentUserEmail: String? { get }

    /// Returns whether a user is currently authenticated.
    var isAuthenticated: Bool { get }

    /// Sign in with email and password.
    func signIn(email: String, password: String) async throws

    /// Create a new account with email and password.
    func signUp(email: String, password: String) async throws

    /// Sign in with Apple ID
    func signInWithApple(authorization: ASAuthorization) async throws

    /// Sign in with Google
    func signInWithGoogle() async throws

    /// Sign in as anonymous guest user
    func signInAsGuest() async throws

    /// Sign out the current user.
    func signOut() async throws
}
