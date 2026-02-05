//
//  SignUpViewModel.swift
//  Whats REAL
//
//  Created by Xcode Assistant on 2/5/26.
//

import Foundation

@MainActor
final class SignUpViewModel: ObservableObject {
    private let authService: AuthServiceProtocol

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func signUp() async {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Email and password are required."
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.signUp(email: email, password: password)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Email and password are required."
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
