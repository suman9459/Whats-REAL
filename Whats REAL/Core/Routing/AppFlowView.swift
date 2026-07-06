//
//  AppFlowView.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 2/5/26.
//

import SwiftUI

/// Main app routing view based on AppState
struct AppFlowView: View {
    @ObservedObject var appState: AppState
    let services: ServiceContainer

    var body: some View {
        switch appState.route {
        case .auth:
            NavigationStack {
                AuthView(
                    authService: services.authService,
                    userService: services.userService
                ) { user in
                    Task {
                        await appState.didAuthenticate(user)
                    }
                }
            }
        case .completeProfile(let user):
            NavigationStack {
                CompleteProfileView(
                    user: user,
                    userService: services.userService,
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
            MainTabView(
                user: user,
                locationService: services.locationService,
                placesService: services.placesService,
                questionService: services.questionService,
                responseService: services.responseService,
                userService: services.userService,
                mediaService: services.mediaService,
                voteService: services.voteService
            ) {
                Task {
                    try? await services.authService.signOut()
                    appState.signOut()
                }
            }
        }
    }
}
