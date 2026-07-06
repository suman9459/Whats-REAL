//
//  WRSecureField.swift
//  Whats REAL
//

import SwiftUI

struct WRSecureField: View {
    let placeholder: String
    @Binding var text: String
    var textContentType: UITextContentType = .password

    @FocusState private var isFocused: Bool
    @State private var isRevealed = false

    var body: some View {
        HStack {
            Group {
                if isRevealed {
                    TextField(placeholder, text: $text)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .textContentType(textContentType)
            .focused($isFocused)

            Button {
                isRevealed.toggle()
            } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 16))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemFill))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isFocused ? Color.blue.opacity(0.6) : Color.clear, lineWidth: 1.5)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

#Preview {
    VStack(spacing: 16) {
        WRSecureField(placeholder: "Password", text: .constant(""))
        WRSecureField(placeholder: "New Password", text: .constant("secret"), textContentType: .newPassword)
    }
    .padding()
}
