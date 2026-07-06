//
//  WRTextField.swift
//  Whats REAL
//

import SwiftUI

struct WRTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never
    var textContentType: UITextContentType? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled(true)
            .keyboardType(keyboardType)
            .if(textContentType != nil) { $0.textContentType(textContentType) }
            .focused($isFocused)
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

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}

#Preview {
    VStack(spacing: 16) {
        WRTextField(placeholder: "Email", text: .constant(""), keyboardType: .emailAddress)
        WRTextField(placeholder: "Name", text: .constant("Test"), autocapitalization: .words)
    }
    .padding()
}
