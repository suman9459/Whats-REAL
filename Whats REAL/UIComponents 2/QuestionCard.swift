//
//  QuestionCard.swift
//  Whats REAL
//

import SwiftUI

struct QuestionCard: View {
    let question: WRQuestion
    let distance: String?
    let responseCount: Int
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Urgency accent stripe
                RoundedRectangle(cornerRadius: 3)
                    .fill(urgencyColor)
                    .frame(width: 4)
                    .padding(.vertical, 12)

                VStack(alignment: .leading, spacing: 10) {
                    // Header: Place + Distance
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundStyle(urgencyColor)

                        Text(question.placeName)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Spacer()

                        if let distance = distance {
                            Label(distance, systemImage: "location.fill")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color(.systemGray6)))
                        }
                    }

                    // Question Text
                    Text(question.text)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    // Footer
                    HStack(spacing: 0) {
                        // Author
                        HStack(spacing: 4) {
                            Circle()
                                .fill(urgencyColor.opacity(0.15))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Text(String(question.authorName.prefix(1)).uppercased())
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(urgencyColor)
                                )
                            Text(question.authorName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        // Urgency pill
                        Text(question.urgencyLevel.displayName.uppercased())
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(urgencyColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(urgencyColor.opacity(0.12)))

                        // Response count
                        HStack(spacing: 3) {
                            Image(systemName: "bubble.left.fill")
                                .font(.caption2)
                            Text("\(responseCount)")
                                .font(.caption2.weight(.medium))
                        }
                        .foregroundStyle(.secondary)
                        .padding(.leading, 10)

                        // Expiry
                        Text(question.timeUntilExpiry)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .padding(.leading, 8)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(
                        color: isPressed
                            ? urgencyColor.opacity(0.12)
                            : Color.black.opacity(0.05),
                        radius: isPressed ? 4 : 10,
                        x: 0,
                        y: isPressed ? 1 : 4
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.75), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    private var urgencyColor: Color {
        switch question.urgencyLevel {
        case .info:      return .blue
        case .happening: return .orange
        case .urgent:    return .red
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ForEach([WRQuestion.UrgencyLevel.info, .happening, .urgent], id: \.rawValue) { level in
            QuestionCard(
                question: WRQuestion(
                    id: level.rawValue,
                    authorId: "u1",
                    authorName: "Sarah Chen",
                    text: "What's the wait time like right now? Is it crowded on weekday evenings?",
                    photoURL: nil,
                    placeId: "p1",
                    placeName: "Blue Bottle Coffee",
                    placeAddress: "123 Main St",
                    lat: 37.7749,
                    lng: -122.4194,
                    geohash: "9q8yy",
                    urgencyLevel: level,
                    createdAt: Date().addingTimeInterval(-3600),
                    expiresAt: Date().addingTimeInterval(1800)
                ),
                distance: "250m away",
                responseCount: 3,
                onTap: {}
            )
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
