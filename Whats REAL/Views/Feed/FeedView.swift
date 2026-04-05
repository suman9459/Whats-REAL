import SwiftUI

struct FeedView: View {
    let user: AppUser
    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Feed")
                .font(.title2.bold())

            Text("User: \(user.id)")
                .foregroundStyle(.secondary)

            Button("Sign Out", action: onSignOut)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        FeedView(user: AppUser(id: "preview", email: "preview@example.com"), onSignOut: {})
    }
}
