//
//  SignUpView.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 7/3/24.
//

import SwiftUI

struct SignUpView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Sign Up")
                .font(.largeTitle).bold()

            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Password", text: $password)
                .textContentType(.newPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Button("Create Account") {
                // TODO: Handle sign up
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
    }
}

#Preview {
    SignUpView()
}
