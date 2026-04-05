import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel: AuthViewModel
    let onAuthenticated: (AppUser) -> Void

    init(authService: AuthServiceProtocol, onAuthenticated: @escaping (AppUser) -> Void) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
        self.onAuthenticated = onAuthenticated
    }

    var body: some View {
        Form {
            Picker("Mode", selection: $viewModel.mode) {
                ForEach(AuthViewModel.Mode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Section("Credentials") {
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)

                SecureField("Password", text: $viewModel.password)
                    .textContentType(viewModel.mode == .signUp ? .newPassword : .password)
            }

            if let message = viewModel.errorMessage {
                Section {
                    Text(message)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task {
                        guard let user = await viewModel.submit() else { return }
                        onAuthenticated(user)
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(viewModel.mode.rawValue)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!viewModel.canSubmit)
            }
        }
        .navigationTitle("Whats REAL")
    }
}

#Preview {
    NavigationStack {
        AuthView(authService: PreviewAuthService(), onAuthenticated: { _ in })
    }
}

private struct PreviewAuthService: AuthServiceProtocol {
    var currentUserID: String? { nil }
    var currentUserEmail: String? { nil }
    var isAuthenticated: Bool { false }

    func signIn(email: String, password: String) async throws {}
    func signUp(email: String, password: String) async throws {}
    func signOut() async throws {}
}
