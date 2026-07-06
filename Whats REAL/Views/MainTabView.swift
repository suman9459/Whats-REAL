//
//  MainTabView.swift
//  Whats REAL
//

import SwiftUI

struct MainTabView: View {
    let user: AppUser
    let locationService: any LocationServiceProtocol
    let placesService: PlacesServiceProtocol
    let questionService: QuestionServiceProtocol
    let responseService: ResponseServiceProtocol
    let userService: UserServiceProtocol
    let mediaService: MediaServiceProtocol
    let voteService: VoteServiceProtocol
    let onSignOut: () -> Void

    var body: some View {
        TabView {
            Tab("Feed", systemImage: "house.fill") {
                NavigationStack {
                    FeedView(
                        user: user,
                        locationService: locationService,
                        questionService: questionService,
                        responseService: responseService,
                        userService: userService,
                        voteService: voteService,
                        onSignOut: onSignOut
                    )
                }
            }

            Tab("Ask", systemImage: "plus.circle.fill") {
                NavigationStack {
                    AskView(
                        user: user,
                        placesService: placesService,
                        questionService: questionService,
                        userService: userService,
                        mediaService: mediaService
                    )
                }
            }

            Tab("Inbox", systemImage: "bell.fill") {
                NavigationStack {
                    InboxPlaceholderView()
                }
            }

            Tab("Profile", systemImage: "person.fill") {
                NavigationStack {
                    ProfileTabView(user: user, onSignOut: onSignOut)
                }
            }
        }
    }
}

// MARK: - Sub-views

private struct ProfileTabView: View {
    let user: AppUser
    let onSignOut: () -> Void

    @State private var showSignOutAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                        .shadow(color: .blue.opacity(0.3), radius: 16, x: 0, y: 6)
                    Text(String(user.email.prefix(1)).uppercased())
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.top, 24)

                VStack(spacing: 6) {
                    Text(user.email)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Label(String(user.id.prefix(8)) + "…", systemImage: "person.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Stats row
                HStack(spacing: 0) {
                    statCell(value: "—", label: "Questions")
                    Divider().frame(height: 36)
                    statCell(value: "—", label: "Answers")
                    Divider().frame(height: 36)
                    statCell(value: "—", label: "Helpful")
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Sign out
                Button(role: .destructive) {
                    showSignOutAlert = true
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)

                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .alert("Sign Out?", isPresented: $showSignOutAlert) {
            Button("Sign Out", role: .destructive) { onSignOut() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You will be returned to the sign-in screen.")
        }
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct InboxPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bell.slash")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)
            Text("Notifications Coming Soon")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
            Text("You'll see replies and activity here once notifications are enabled.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .navigationTitle("Inbox")
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    MainTabView(
        user: AppUser(id: "preview", email: "preview@example.com", profileComplete: true),
        locationService: StubLocationService(),
        placesService: StubPlacesService(),
        questionService: StubQuestionService(),
        responseService: StubResponseService(),
        userService: StubUserService(),
        mediaService: StubMediaService(),
        voteService: StubVoteService(),
        onSignOut: {}
    )
}
