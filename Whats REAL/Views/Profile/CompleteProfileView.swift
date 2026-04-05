import SwiftUI

struct CompleteProfileView: View {
    let user: AppUser
    let onCompleteProfile: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Complete Profile")
                .font(.title2.bold())

            Text("Signed in as: \(user.email)")
                .foregroundStyle(.secondary)

            Button("Mark Profile Complete", action: onCompleteProfile)
                .buttonStyle(.borderedProminent)

            Button("Sign Out", action: onSignOut)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        CompleteProfileView(
            user: AppUser(id: "preview", email: "preview@example.com"),
            onCompleteProfile: {},
            onSignOut: {}
        )
    }
}
