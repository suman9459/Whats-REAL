import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

final class FirebaseAuthService: AuthServiceProtocol, @unchecked Sendable {

    // Store the nonce for Apple Sign-In security
    private var currentNonce: String?

    var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    var currentUserEmail: String? {
        Auth.auth().currentUser?.email
    }

    var isAuthenticated: Bool {
        currentUserID != nil
    }

    func signIn(email: String, password: String) async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        _ = try await Auth.auth().createUser(withEmail: email, password: password)
    }

    func signInWithApple(authorization: ASAuthorization) async throws {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple ID credential"])
        }

        guard let nonce = currentNonce else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: A login callback was received, but no login request was sent."])
        }

        guard let appleIDToken = appleIDCredential.identityToken else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])
        }

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string from data"])
        }

        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: idTokenString,
            rawNonce: nonce
        )

        _ = try await Auth.auth().signIn(with: credential)
    }

    func signInWithGoogle() async throws {
        // Google Sign-In implementation
        // Note: This requires GoogleSignIn SDK and additional setup
        // For now, throwing an error to indicate it needs implementation
        throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google Sign-In requires GoogleSignIn SDK setup"])
    }

    func signInAsGuest() async throws {
        _ = try await Auth.auth().signInAnonymously()
    }

    func signOut() async throws {
        try Auth.auth().signOut()
    }

    // MARK: - Helper Methods for Apple Sign-In

    /// Generate a cryptographically secure random nonce for Apple Sign-In
    func generateNonce() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return nonce
    }

    /// Generate SHA256 hash of the nonce
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }
}
