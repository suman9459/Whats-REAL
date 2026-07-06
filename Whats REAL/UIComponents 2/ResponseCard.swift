//
//  ResponseCard.swift
//  Whats REAL
//

import SwiftUI

struct ResponseCard: View {
    let response: WRResponse
    let onHelpful: () -> Void

    @State private var isHelpfulPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Avatar + Author + Time
            HStack(spacing: 10) {
                // Avatar initials circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [avatarColor, avatarColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 34, height: 34)
                    .overlay(
                        Text(String(response.responderName.prefix(1)).uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text(response.responderName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(response.timeAgo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Response type badge
                if response.type == .photo || response.type == .textWithPhoto {
                    Image(systemName: "photo")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Response text
            if let text = response.text, !text.isEmpty {
                Text(text)
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Photo
            if let photoURL = response.photoURL, !photoURL.isEmpty {
                AsyncImage(url: URL(string: photoURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray5))
                        .frame(height: 120)
                        .overlay(ProgressView())
                }
            }

            // Helpful button
            HStack {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isHelpfulPressed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        isHelpfulPressed = false
                        onHelpful()
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: response.helpfulCount > 0 ? "hand.thumbsup.fill" : "hand.thumbsup")
                            .font(.system(size: 13))
                        Text(response.helpfulCount > 0 ? "Helpful (\(response.helpfulCount))" : "Helpful")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(response.helpfulCount > 0 ? .blue : .secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(
                            response.helpfulCount > 0
                                ? Color.blue.opacity(0.1)
                                : Color(.systemGray6)
                        )
                    )
                }
                .scaleEffect(isHelpfulPressed ? 0.9 : 1.0)

                Spacer()
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private var avatarColor: Color {
        let colors: [Color] = [.blue, .purple, .green, .orange, .pink, .teal, .indigo]
        let index = abs(response.responderName.hashValue) % colors.count
        return colors[index]
    }
}

#Preview {
    VStack(spacing: 12) {
        ResponseCard(
            response: WRResponse(
                id: "1", responderId: "u2", responderName: "John Smith",
                type: .text,
                text: "Yes, it's usually about a 15-minute wait on weekends. Weekday mornings are much better!",
                photoURL: nil, createdAt: Date().addingTimeInterval(-600), helpfulCount: 5
            ),
            onHelpful: {}
        )
        ResponseCard(
            response: WRResponse(
                id: "2", responderId: "u3", responderName: "Sarah Lee",
                type: .text, text: "Just got here, no wait at all right now.", photoURL: nil,
                createdAt: Date().addingTimeInterval(-120), helpfulCount: 0
            ),
            onHelpful: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
