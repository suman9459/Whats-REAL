//
//  WRPrimaryButton.swift
//  Whats REAL
//

import SwiftUI

struct WRPrimaryButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    @State private var isPressed = false

    init(
        _ title: String,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isEnabled
                            ? LinearGradient(colors: [.blue, Color(hue: 0.62, saturation: 0.9, brightness: 0.85)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color(.systemGray3), Color(.systemGray3)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: isEnabled ? .blue.opacity(0.35) : .clear, radius: 10, x: 0, y: 5)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
        }
        .disabled(!isEnabled || isLoading)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        WRPrimaryButton("Sign In") {}
        WRPrimaryButton("Loading...", isLoading: true) {}
        WRPrimaryButton("Disabled", isEnabled: false) {}
    }
    .padding()
}
