//
//  AskView.swift
//  Whats REAL
//

import SwiftUI

private let questionCharLimit = 280

struct AskView: View {
    let placesService: PlacesServiceProtocol

    @StateObject private var viewModel: AskViewModel
    @State private var showPlacePicker = false
    @State private var showSuccess = false
    @FocusState private var questionFocused: Bool

    init(
        user: AppUser,
        placesService: PlacesServiceProtocol,
        questionService: QuestionServiceProtocol,
        userService: UserServiceProtocol,
        mediaService: MediaServiceProtocol
    ) {
        self.placesService = placesService
        _viewModel = StateObject(wrappedValue: AskViewModel(
            user: user,
            questionService: questionService,
            userService: userService,
            mediaService: mediaService
        ))
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            if showSuccess {
                successView
                    .transition(.scale.combined(with: .opacity))
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        formContent
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
                .transition(.opacity)
            }
        }
        .navigationTitle("Ask a Question")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: showSuccess)
        .sheet(isPresented: $showPlacePicker) {
            WRPlacePickerView(placesService: placesService) { place in
                viewModel.selectedPlace = place
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var formContent: some View {
        VStack(spacing: 20) {
            // Step 1 — Question
            formSection(step: 1, title: "Your Question") {
                VStack(alignment: .trailing, spacing: 6) {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        questionFocused ? Color.blue.opacity(0.5) : Color.clear,
                                        lineWidth: 1.5
                                    )
                            )

                        if viewModel.questionText.isEmpty {
                            Text("What do you want to know about this place?")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                        }

                        TextEditor(text: $viewModel.questionText)
                            .focused($questionFocused)
                            .frame(minHeight: 110)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                    }
                    .animation(.easeInOut(duration: 0.2), value: questionFocused)

                    // Character counter
                    let count = viewModel.questionText.count
                    let remaining = questionCharLimit - count
                    Text("\(count) / \(questionCharLimit)")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(remaining < 20 ? (remaining < 0 ? .red : .orange) : .secondary)
                        .animation(.easeInOut(duration: 0.15), value: remaining)
                }
            }

            // Step 2 — Urgency
            formSection(step: 2, title: "How urgent is this?") {
                HStack(spacing: 10) {
                    ForEach([WRQuestion.UrgencyLevel.info, .happening, .urgent], id: \.rawValue) { level in
                        urgencyButton(level: level)
                    }
                }
            }

            // Step 3 — Location
            formSection(step: 3, title: "Where are you asking about?") {
                Button { showPlacePicker = true } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(viewModel.selectedPlace != nil
                                    ? Color.blue.opacity(0.12)
                                    : Color(.systemGray5))
                                .frame(width: 38, height: 38)
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(viewModel.selectedPlace != nil ? .blue : .secondary)
                        }

                        if let place = viewModel.selectedPlace {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(place.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                Text(place.address)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        } else {
                            Text("Select a place")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        viewModel.selectedPlace != nil ? Color.blue.opacity(0.4) : Color.clear,
                                        lineWidth: 1.5
                                    )
                            )
                    )
                }
            }

            // Post button
            WRPrimaryButton(
                "Post Question",
                isLoading: viewModel.isPosting,
                isEnabled: viewModel.canPost
            ) {
                Task {
                    if await viewModel.postQuestion() {
                        withAnimation {
                            showSuccess = true
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
    }

    private func urgencyButton(level: WRQuestion.UrgencyLevel) -> some View {
        let isSelected = viewModel.selectedUrgency == level
        let color: Color = switch level {
        case .info: .blue
        case .happening: .orange
        case .urgent: .red
        }
        let expiry: String = switch level {
        case .info: "24h"
        case .happening: "1h"
        case .urgent: "30m"
        }

        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.selectedUrgency = level
            }
        } label: {
            VStack(spacing: 4) {
                Text(level.displayName)
                    .font(.system(size: 13, weight: .semibold))
                Text(expiry)
                    .font(.system(size: 11, weight: .medium))
                    .opacity(0.75)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? color : Color.clear, lineWidth: 1.5)
                    )
            )
            .foregroundStyle(isSelected ? .white : .primary)
            .scaleEffect(isSelected ? 1.03 : 1.0)
        }
    }

    @ViewBuilder
    private func formSection<Content: View>(
        step: Int,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("\(step)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color.blue))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            content()
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 110, height: 110)
                Circle()
                    .fill(Color.green.opacity(0.07))
                    .frame(width: 140, height: 140)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
            }

            VStack(spacing: 8) {
                Text("Question Posted!")
                    .font(.title2.weight(.bold))
                Text("Your question is live. Locals nearby will answer it shortly.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if let msg = viewModel.successMessage {
                Text(msg)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 40)
                    .multilineTextAlignment(.center)
            }

            WRPrimaryButton("Ask Another Question") {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                viewModel.resetForm()
                withAnimation { showSuccess = false }
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        AskView(
            user: AppUser(id: "preview", email: "preview@example.com", profileComplete: true),
            placesService: StubPlacesService(),
            questionService: StubQuestionService(),
            userService: StubUserService(),
            mediaService: StubMediaService()
        )
    }
}
