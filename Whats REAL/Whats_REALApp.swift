//
//  Whats_REALApp.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 7/3/24.
//

import SwiftUI
import FirebaseCore

@main
struct Whats_REALApp: App {
    @StateObject private var router: AppRouter
    private let services: ServiceContainer

    init() {
        FirebaseApp.configure()
        // Setup services (DI)
        let auth = FirebaseAuthService()
        self.services = ServiceContainer(authService: auth)

        // Choose initial route based on auth state
        if let userID = auth.currentUserID {
            // In a real app, fetch profile document to decide route
            let user = AppUser(id: userID, email: "", profileComplete: false)
            _router = StateObject(wrappedValue: AppRouter(initial: .feed(user)))
        } else {
            _router = StateObject(wrappedValue: AppRouter(initial: .auth))
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(router: router, services: services)
        }
    }
}
// MARK: - RootView
private struct RootView: View {
    @ObservedObject var router: AppRouter
    let services: ServiceContainer

    var body: some View {
        switch router.route {
        case .auth:
            let vm = SignUpViewModel(authService: services.authService)
            NavigationStack {
                SignUpView()
            }
        case .completeProfile(let user):
            // Placeholder until Profile feature is implemented
            NavigationStack { Text("Complete Profile for: \(user.email)") }
        case .feed(let user):
            // Placeholder until Feed feature is implemented
            NavigationStack { Text("Feed for user: \(user.id)") }
        }
    }
}

