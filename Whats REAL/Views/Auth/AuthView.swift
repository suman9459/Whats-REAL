//
//  AuthView.swift
//  Whats REAL
//

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @StateObject private var viewModel: AuthViewModel
    let authService: AuthServiceProtocol
    let onAuthenticated: (AppUser) -> Void

    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: CGFloat = 0
    @State private var formOpacity: CGFloat = 0

    init(
        authService: AuthServiceProtocol,
        userService: UserServiceProtocol,
        onAuthenticated: @escaping (AppUser) -> Void
    ) {
        self.authService = authService
        _viewModel = StateObject(wrappedValue: AuthViewModel(
            authService: authService,
            userService: userService
        ))
        self.onAuthenticated = onAuthenticated
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                logoSection
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                formSection
                    .opacity(formOpacity)
            }
            .padding(.horizontal, 20)
            .padding(.top, 56)
            .padding(.bottom, 40)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.75).delay(0.05)) {
                logoScale  = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.35).delay(0.2)) {
                formOpacity = 1.0
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
    }

    // MARK: - Logo

    private var logoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.08))
                    .frame(width: 128, height: 128)
                Circle()
                    .fill(Color.blue.opacity(0.13))
                    .frame(width: 100, height: 100)
                Image(systemName: "location.fill.viewfinder")
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 6) {
                Text("What's REAL")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("Hyperlocal answers, instantly")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 20) {
            // Mode picker
            Picker("Mode", selection: $viewModel.mode) {
                ForEach(AuthViewModel.Mode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            // Card container
            VStack(spacing: 14) {
                WRTextField(
                    placeholder: "Email address",
                    text: $viewModel.email,
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress
                )

                WRSecureField(
                    placeholder: "Password",
                    text: $viewModel.password,
                    textContentType: viewModel.mode == .signUp ? .newPassword : .password
                )
            }

            // Error
            if let message = viewModel.errorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                    Text(message)
                        .font(.caption)
                }
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Primary action
            WRPrimaryButton(
                viewModel.mode.rawValue,
                isLoading: viewModel.isLoading,
                isEnabled: viewModel.canSubmit
            ) {
                Task {
                    guard let user = await viewModel.submit() else { return }
                    onAuthenticated(user)
                }
            }

            // Divider
            HStack {
                Rectangle().fill(Color(.separator)).frame(height: 0.5)
                Text("OR")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                Rectangle().fill(Color(.separator)).frame(height: 0.5)
            }
            .padding(.vertical, 2)

            // Apple Sign-In
            if let firebaseService = authService as? FirebaseAuthService {
                SignInWithAppleButton(
                    onRequest: {
                        let nonce = firebaseService.generateNonce()
                        return firebaseService.sha256(nonce)
                    },
                    onCompletion: { result in
                        Task {
                            switch result {
                            case .success(let authorization):
                                guard let user = await viewModel.signInWithApple(authorization: authorization) else { return }
                                onAuthenticated(user)
                            case .failure:
                                viewModel.errorMessage = "Apple Sign-In failed"
                            }
                        }
                    }
                )
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            // Guest
            Button {
                Task {
                    guard let user = await viewModel.signInAsGuest() else { return }
                    onAuthenticated(user)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 15))
                    Text("Continue as Guest")
                        .font(.system(size: 15, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(.systemGray5))
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(viewModel.isLoading)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    AuthView(
        authService: PreviewAuthService(),
        userService: PreviewUserService(),
        onAuthenticated: { _ in }
    )
}

private struct PreviewAuthService: AuthServiceProtocol {
    var currentUserID: String? { nil }
    var currentUserEmail: String? { nil }
    var isAuthenticated: Bool { false }
    func signIn(email: String, password: String) async throws {}
    func signUp(email: String, password: String) async throws {}
    func signInWithApple(authorization: ASAuthorization) async throws {}
    func signInWithGoogle() async throws {}
    func signInAsGuest() async throws {}
    func signOut() async throws {}
}

@MainActor
private struct PreviewUserService: UserServiceProtocol {
    func fetchProfile(uid: String) async throws -> WRUserProfile? { nil }
    func upsertProfile(uid: String, profile: WRUserProfile) async throws {}
    func isProfileComplete(uid: String) async throws -> Bool { false }
}
