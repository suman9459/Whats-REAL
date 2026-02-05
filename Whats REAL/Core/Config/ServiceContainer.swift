//
//  ServiceContainer.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 2/5/26.
//


import Foundation

/// Centralized dependency container for services. Keep minimal and protocol-oriented.
public struct ServiceContainer: Sendable {
    public let authService: AuthServiceProtocol

    public init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
}