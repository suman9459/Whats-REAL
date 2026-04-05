import Foundation

@MainActor
final class AppState: ObservableObject {
    enum AuthState: Equatable {
        case signedOut
        case signedIn(AppUser)
    }

    enum ProfileState: Equatable {
        case unknown
        case incomplete
        case complete
    }

    @Published private(set) var authState: AuthState = .signedOut
    @Published private(set) var profileState: ProfileState = .unknown

    var route: AppRoute {
        switch authState {
        case .signedOut:
            return .auth
        case .signedIn(let user):
            switch profileState {
            case .complete:
                return .feed(user)
            case .unknown, .incomplete:
                return .completeProfile(user)
            }
        }
    }

    init(authService: AuthServiceProtocol) {
        bootstrap(authService: authService)
    }

    func bootstrap(authService: AuthServiceProtocol) {
        guard let userID = authService.currentUserID else {
            authState = .signedOut
            profileState = .unknown
            return
        }

        let user = AppUser(
            id: userID,
            email: authService.currentUserEmail ?? "",
            profileComplete: false
        )
        authState = .signedIn(user)
        profileState = .incomplete
    }

    func didAuthenticate(_ user: AppUser) {
        authState = .signedIn(user)
        profileState = user.profileComplete ? .complete : .incomplete
    }

    func completeProfile() {
        guard case .signedIn(let user) = authState else { return }
        authState = .signedIn(
            AppUser(id: user.id, email: user.email, profileComplete: true)
        )
        profileState = .complete
    }

    func signOut() {
        authState = .signedOut
        profileState = .unknown
    }
}
