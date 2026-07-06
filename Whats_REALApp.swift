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
    // Register AppDelegate for Firebase configuration
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var appState: AppState
    private let services: ServiceContainer

    init() {
        let authService = FirebaseAuthService()
        services = ServiceContainer.makeDefault(authService: authService) //makeStubContainer(authService: authService)
        _appState = StateObject(wrappedValue: AppState(authService: authService))
    }

    var body: some Scene {
        WindowGroup {
            AppFlowView(appState: appState, services: services)
        }
    }
}
