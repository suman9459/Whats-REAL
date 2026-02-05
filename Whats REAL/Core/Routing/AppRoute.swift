//
//  AppRoute.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 2/5/26.
//


import Foundation
import SwiftUI

/// High-level routes for the app. Keep it small and focused.
public enum AppRoute: Equatable, Sendable {
    case auth
    case completeProfile(AppUser)
    case feed(AppUser)
}

/// Observable router that drives top-level navigation.
@MainActor
public final class AppRouter: ObservableObject {
    @Published public var route: AppRoute

    public init(initial: AppRoute) {
        self.route = initial
    }

    public func go(to newRoute: AppRoute) {
        self.route = newRoute
    }
}