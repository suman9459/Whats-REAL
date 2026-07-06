//
//  SignInWithAppleButton.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/5/26.
//

import SwiftUI
import AuthenticationServices

/// Coordinator to handle Apple Sign-In authorization
@MainActor
final class SignInWithAppleCoordinator: NSObject, ASAuthorizationControllerDelegate {
    private let onCompletion: (Result<ASAuthorization, Error>) -> Void

    init(onCompletion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.onCompletion = onCompletion
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        onCompletion(.success(authorization))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onCompletion(.failure(error))
    }
}

/// SwiftUI wrapper for Sign in with Apple button
struct SignInWithAppleButton: View {
    let onRequest: () -> String // Returns nonce
    let onCompletion: (Result<ASAuthorization, Error>) -> Void

    @State private var coordinator: SignInWithAppleCoordinator?

    var body: some View {
        SignInWithAppleButtonRepresentable(
            onRequest: onRequest,
            onCompletion: onCompletion
        )
        .frame(height: 50)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// UIViewRepresentable for ASAuthorizationAppleIDButton
struct SignInWithAppleButtonRepresentable: UIViewRepresentable {
    let onRequest: () -> String
    let onCompletion: (Result<ASAuthorization, Error>) -> Void

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onRequest: onRequest, onCompletion: onCompletion)
    }

    @MainActor
    final class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        let onRequest: () -> String
        let onCompletion: (Result<ASAuthorization, Error>) -> Void

        init(onRequest: @escaping () -> String, onCompletion: @escaping (Result<ASAuthorization, Error>) -> Void) {
            self.onRequest = onRequest
            self.onCompletion = onCompletion
        }

        @objc func handleAuthorizationAppleIDButtonPress() {
            let nonce = onRequest()

            // Use Firebase's helper to generate SHA256 hash
            // For now we'll just use the nonce directly, but in production
            // you should hash it with SHA256
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = nonce

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            onCompletion(.success(authorization))
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            onCompletion(.failure(error))
        }

        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else {
                fatalError("No window found")
            }
            return window
        }
    }
}
