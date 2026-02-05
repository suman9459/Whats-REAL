import Foundation
import FirebaseAuth

final class FirebaseAuthService: AuthServiceProtocol, @unchecked Sendable {
    
    var currentUserID: String? {
        Auth.auth().currentUser?.uid
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
    
    func signOut() async throws {
        try Auth.auth().signOut()
    }
}
