import SwiftUI

struct AppFlowView: View {
    @ObservedObject var appState: AppState
    let services: ServiceContainer

    var body: some View {
        switch appState.route {
        case .auth:
            NavigationStack {
                AuthView(authService: services.authService) { user in
                    appState.didAuthenticate(user)
                }
            }
        case .completeProfile(let user):
            NavigationStack {
                CompleteProfileView(
                    user: user,
                    onCompleteProfile: appState.completeProfile,
                    onSignOut: {
                        Task {
                            try? await services.authService.signOut()
                            appState.signOut()
                        }
                    }
                )
            }
        case .feed(let user):
            NavigationStack {
                FeedView(user: user) {
                    Task {
                        try? await services.authService.signOut()
                        appState.signOut()
                    }
                }
            }
        }
    }
}
