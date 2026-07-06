//
//  QuestionDetailView.swift
//  Whats REAL
//

import SwiftUI

struct QuestionDetailSheetView: View {
    let question: WRQuestion
    let user: AppUser
    let responseService: ResponseServiceProtocol
    let userService: UserServiceProtocol

    @StateObject private var viewModel: QuestionDetailViewModel
    @FocusState private var inputFocused: Bool

    init(
        question: WRQuestion,
        user: AppUser,
        responseService: ResponseServiceProtocol,
        userService: UserServiceProtocol
    ) {
        self.question = question
        self.user = user
        self.responseService = responseService
        self.userService = userService
        _viewModel = StateObject(wrappedValue: QuestionDetailViewModel(
            question: question,
            user: user,
            responseService: responseService,
            userService: userService
        ))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    questionHeader
                    responsesSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
        }
        .safeAreaInset(edge: .bottom) {
            responseInputBar
        }
        .navigationTitle("Question")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.regularMaterial, for: .navigationBar)
        .onAppear { viewModel.startObserving() }
        .onDisappear { viewModel.stopObserving() }
    }

    // MARK: - Question Header Card

    private var questionHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Urgency stripe at top
            Rectangle()
                .fill(urgencyColor)
                .frame(height: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            VStack(alignment: .leading, spacing: 12) {
                // Badge row
                HStack(spacing: 8) {
                    Label(question.urgencyLevel.displayName.uppercased(), systemImage: urgencyIcon)
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(urgencyColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(urgencyColor.opacity(0.12)))

                    Spacer()

                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(question.timeUntilExpiry)
                        .font(.caption2.monospacedDigit())
                }
                .foregroundStyle(.secondary)

                // Question text
                Text(question.text)
                    .font(.system(size: 18, weight: .semibold))
                    .fixedSize(horizontal: false, vertical: true)

                Divider()

                // Meta row
                HStack(spacing: 12) {
                    Label(question.placeName, systemImage: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .lineLimit(1)

                    Spacer()

                    HStack(spacing: 4) {
                        Circle()
                            .fill(urgencyColor.opacity(0.2))
                            .frame(width: 18, height: 18)
                            .overlay(
                                Text(String(question.authorName.prefix(1)).uppercased())
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(urgencyColor)
                            )
                        Text(question.authorName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: urgencyColor.opacity(0.07), radius: 10, x: 0, y: 3)
    }

    // MARK: - Responses Section

    private var responsesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !viewModel.responses.isEmpty {
                Text("\(viewModel.responses.count) Answer\(viewModel.responses.count == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }

            if viewModel.isLoading {
                HStack {
                    ProgressView()
                    Text("Loading answers…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else if viewModel.responses.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 38, weight: .light))
                        .foregroundStyle(.tertiary)
                        .symbolRenderingMode(.hierarchical)
                    Text("No answers yet")
                        .font(.subheadline.weight(.medium))
                    Text("Be the first to share what you know!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ForEach(viewModel.responses) { response in
                    ResponseCard(response: response, onHelpful: {})
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.responses.count)
            }
        }
    }

    // MARK: - Floating Response Input Bar

    private var responseInputBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(alignment: .bottom, spacing: 10) {
                // Avatar
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Text(String(user.email.prefix(1)).uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.blue)
                    )

                // Expandable input
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    inputFocused ? Color.blue.opacity(0.5) : Color.clear,
                                    lineWidth: 1.5
                                )
                        )

                    if viewModel.responseText.isEmpty {
                        Text("What do you know about this?")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .allowsHitTesting(false)
                    }

                    TextField("", text: $viewModel.responseText, axis: .vertical)
                        .lineLimit(1...5)
                        .focused($inputFocused)
                        .font(.system(size: 15))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                }
                .frame(minHeight: 40)
                .animation(.easeInOut(duration: 0.2), value: inputFocused)

                // Send button
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    Task {
                        _ = await viewModel.submitTextResponse()
                        inputFocused = false
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(viewModel.canSubmitText ? Color.blue : Color(.systemGray4))
                            .frame(width: 36, height: 36)
                        Image(systemName: viewModel.isSubmitting ? "ellipsis" : "arrow.up")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .disabled(!viewModel.canSubmitText || viewModel.isSubmitting)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.canSubmitText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.regularMaterial)
        }
    }

    private var urgencyColor: Color {
        switch question.urgencyLevel {
        case .info:      return .blue
        case .happening: return .orange
        case .urgent:    return .red
        }
    }

    private var urgencyIcon: String {
        switch question.urgencyLevel {
        case .info:      return "info.circle"
        case .happening: return "bolt.fill"
        case .urgent:    return "exclamationmark.2"
        }
    }
}

#Preview {
    NavigationStack {
        QuestionDetailSheetView(
            question: WRQuestion(
                id: "q1", authorId: "u1", authorName: "Sarah Chen",
                text: "What's the wait time like right now? Is it crowded on weekday evenings?",
                photoURL: nil, placeId: "p1", placeName: "Blue Bottle Coffee",
                placeAddress: "123 Main St", lat: 37.7749, lng: -122.4194,
                geohash: "9q8yy", urgencyLevel: .happening,
                createdAt: Date(), expiresAt: Date().addingTimeInterval(3600)
            ),
            user: AppUser(id: "u2", email: "me@example.com", profileComplete: true),
            responseService: StubResponseService(),
            userService: StubUserService()
        )
    }
}
