import Foundation
import AuthenticationServices

@MainActor
final class AuthViewModel: ObservableObject {
    enum Mode: String, CaseIterable, Identifiable {
        case signIn = "Sign In"
        case signUp = "Create Account"
        var id: String { rawValue }
    }

    private let authService: AuthServiceProtocol
    private let userService: UserServiceProtocol

    @Published var mode: Mode = .signIn
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    init(authService: AuthServiceProtocol, userService: UserServiceProtocol) {
        self.authService = authService
        self.userService = userService
    }

    var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !password.isEmpty
        && !isLoading
    }

    func submit() async -> AppUser? {
        guard canSubmit else {
            errorMessage = "Email and password are required."
            return nil
        }

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            switch mode {
            case .signIn:
                try await authService.signIn(email: email, password: password)
            case .signUp:
                try await authService.signUp(email: email, password: password)
            }
            return await resolveAppUser(fallbackEmail: email)
        } catch let error as NSError {
            switch error.code {
            case 17007: errorMessage = "This email is already registered. Try signing in instead."
            case 17008: errorMessage = "Invalid email format."
            case 17026: errorMessage = "Password is too weak. Use at least 6 characters."
            case 17011: errorMessage = "No account found with this email."
            case 17009: errorMessage = "Incorrect password. Please try again."
            case 17020: errorMessage = "Network error. Please check your connection."
            default:    errorMessage = error.localizedDescription
            }
            return nil
        }
    }

    func signInWithApple(authorization: ASAuthorization) async -> AppUser? {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.signInWithApple(authorization: authorization)
            return await resolveAppUser(fallbackEmail: "apple_user@private.com")
        } catch {
            errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
            return nil
        }
    }

    func signInAsGuest() async -> AppUser? {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.signInAsGuest()
            guard let userID = authService.currentUserID else {
                errorMessage = "Unable to resolve guest user."
                return nil
            }
            return AppUser(id: userID, email: "guest@whatsreal.app", profileComplete: false)
        } catch {
            errorMessage = "Guest sign-in failed: \(error.localizedDescription)"
            return nil
        }
    }

    private func resolveAppUser(fallbackEmail: String) async -> AppUser? {
        guard let userID = authService.currentUserID else {
            errorMessage = "Unable to resolve signed-in user."
            return nil
        }
        let resolvedEmail = authService.currentUserEmail ?? fallbackEmail
        let existingProfile = try? await userService.fetchProfile(uid: userID)
        let profileComplete = existingProfile?.profileComplete ?? false
        return AppUser(id: userID, email: resolvedEmail, profileComplete: profileComplete)
    }
}
