//
//  ProfileSetupView.swift
//  Whats REAL
//

import SwiftUI

struct ProfileSetupView: View {
    let user: AppUser
    let userService: UserServiceProtocol
    let onComplete: () -> Void

    @StateObject private var viewModel: ProfileSetupViewModel
    @FocusState private var nameFocused: Bool
    @State private var appear = false

    init(user: AppUser, userService: UserServiceProtocol, onComplete: @escaping () -> Void) {
        self.user = user
        self.userService = userService
        self.onComplete = onComplete
        _viewModel = StateObject(wrappedValue: ProfileSetupViewModel(
            userId: user.id,
            userService: userService
        ))
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                // Avatar hero
                avatarSection
                    .opacity(appear ? 1 : 0)
                    .scaleEffect(appear ? 1 : 0.85)

                // Form card
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Display Name", systemImage: "person.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)

                        WRTextField(
                            placeholder: "How should people see you?",
                            text: $viewModel.displayName,
                            autocapitalization: .words,
                            textContentType: .name
                        )
                        .focused($nameFocused)
                    }

                    if !viewModel.displayName.isEmpty && viewModel.displayName.count < 2 {
                        Label("Must be at least 2 characters", systemImage: "exclamationmark.circle")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    WRPrimaryButton(
                        "Get Started",
                        isLoading: viewModel.isSaving,
                        isEnabled: viewModel.canSave
                    ) {
                        Task {
                            if await viewModel.saveProfile() { onComplete() }
                        }
                    }

                    Text("Your name is visible to other users in your community.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 56)
            .padding(.bottom, 40)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.75).delay(0.08)) {
                appear = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                nameFocused = true
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.displayName.count)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var avatarSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.08))
                    .frame(width: 128, height: 128)
                Circle()
                    .fill(Color.blue.opacity(0.14))
                    .frame(width: 100, height: 100)

                if viewModel.displayName.trimmingCharacters(in: .whitespaces).isEmpty {
                    Image(systemName: "person.fill")
                        .font(.system(size: 42, weight: .medium))
                        .foregroundStyle(Color.blue.opacity(0.5))
                } else {
                    Text(String(viewModel.displayName.trimmingCharacters(in: .whitespaces).prefix(1)).uppercased())
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundStyle(.blue)
                        .contentTransition(.identity)
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: viewModel.displayName.isEmpty)

            VStack(spacing: 6) {
                Text("Welcome to What's REAL")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("Set your name so the community knows who you are")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
        }
    }
}

@MainActor
final class ProfileSetupViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let userId: String
    private let userService: UserServiceProtocol

    var canSave: Bool {
        displayName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    init(userId: String, userService: UserServiceProtocol) {
        self.userId = userId
        self.userService = userService
    }

    func saveProfile() async -> Bool {
        guard canSave else { return false }

        isSaving = true
        errorMessage = nil

        do {
            let profile = WRUserProfile(
                uid: userId,
                displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
                profileComplete: true,
                createdAt: Date(),
                age: nil,
                gender: nil,
                socialStatus: nil,
                trustScore: nil,
                fcmToken: nil
            )
            try await userService.upsertProfile(uid: userId, profile: profile)
            isSaving = false
            return true
        } catch {
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
            isSaving = false
            return false
        }
    }
}

#Preview {
    ProfileSetupView(
        user: AppUser(id: "preview", email: "test@example.com", profileComplete: false),
        userService: StubUserService(),
        onComplete: {}
    )
}
