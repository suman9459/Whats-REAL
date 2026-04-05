import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    enum Mode: String, CaseIterable, Identifiable {
        case signIn = "Sign In"
        case signUp = "Create Account"

        var id: String { rawValue }
    }

    private let authService: AuthServiceProtocol

    @Published var mode: Mode = .signIn
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    init(authService: AuthServiceProtocol) {
        self.authService = authService
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

            guard let userID = authService.currentUserID else {
                errorMessage = "Unable to resolve signed-in user."
                return nil
            }

            let resolvedEmail = authService.currentUserEmail ?? email
            return AppUser(id: userID, email: resolvedEmail, profileComplete: false)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
