//
//  CompleteProfileView.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 7/3/24.
//

import SwiftUI

/// Wrapper view for profile completion flow
struct CompleteProfileView: View {
    let user: AppUser
    let userService: UserServiceProtocol
    let onCompleteProfile: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main Profile Setup
            ProfileSetupView(
                user: user,
                userService: userService,
                onComplete: onCompleteProfile
            )

            // Sign Out Button
            Button(action: onSignOut) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundStyle(.red)
                    .padding()
            }
        }
    }
}

#Preview {
    NavigationStack {
        CompleteProfileView(
            user: AppUser(id: "preview", email: "preview@example.com", profileComplete: false),
            userService: StubUserService(),
            onCompleteProfile: {},
            onSignOut: {}
        )
    }
}
