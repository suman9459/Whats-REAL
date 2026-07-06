//
//  FeedView.swift
//  Whats REAL
//

import SwiftUI
import CoreLocation

struct FeedView: View {
    let user: AppUser
    let locationService: any LocationServiceProtocol
    let questionService: QuestionServiceProtocol
    let responseService: ResponseServiceProtocol
    let userService: UserServiceProtocol
    let voteService: VoteServiceProtocol
    let onSignOut: () -> Void

    @StateObject private var viewModel: FeedViewModel
    @State private var selectedUrgency: WRQuestion.UrgencyLevel?
    @State private var selectedQuestion: WRQuestion?
    @State private var headerVisible = false

    init(
        user: AppUser,
        locationService: any LocationServiceProtocol,
        questionService: QuestionServiceProtocol,
        responseService: ResponseServiceProtocol,
        userService: UserServiceProtocol,
        voteService: VoteServiceProtocol,
        onSignOut: @escaping () -> Void
    ) {
        self.user = user
        self.locationService = locationService
        self.questionService = questionService
        self.responseService = responseService
        self.userService = userService
        self.voteService = voteService
        self.onSignOut = onSignOut
        _viewModel = StateObject(wrappedValue: FeedViewModel(
            questionService: questionService,
            locationService: locationService
        ))
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Location permission banner
                if !hasLocationPermission {
                    LocationPermissionBanner(
                        onRequestPermission: { locationService.requestPermission() }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: hasLocationPermission)
                }

                // Urgency filter chips
                urgencyFilterBar
                    .padding(.vertical, 10)

                // Content
                Group {
                    if viewModel.isLoading && viewModel.questions.isEmpty {
                        loadingView
                    } else if filteredQuestions.isEmpty {
                        emptyView
                    } else {
                        questionList
                    }
                }
            }
        }
        .navigationTitle("What's REAL")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.regularMaterial, for: .navigationBar)
        .onAppear {
            locationService.startUpdatingIfAuthorized()
            viewModel.startObserving()
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                headerVisible = true
            }
        }
        .onDisappear { viewModel.stopObserving() }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
        .sheet(item: $selectedQuestion) { question in
            NavigationStack {
                QuestionDetailSheetView(
                    question: question,
                    user: user,
                    responseService: responseService,
                    userService: userService
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { selectedQuestion = nil }
                    }
                }
            }
            .presentationCornerRadius(24)
            .presentationDragIndicator(.visible)
        }
    }

    private var urgencyFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    label: "All",
                    icon: "line.3.horizontal.decrease.circle",
                    color: .primary,
                    isSelected: selectedUrgency == nil
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedUrgency = nil
                    }
                }

                ForEach([WRQuestion.UrgencyLevel.info, .happening, .urgent], id: \.rawValue) { level in
                    FilterChip(
                        label: level.displayName,
                        icon: level.icon,
                        color: level.color,
                        isSelected: selectedUrgency == level
                    ) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedUrgency = selectedUrgency == level ? nil : level
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var loadingView: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(0..<5, id: \.self) { _ in
                    QuestionCardSkeleton()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: hasLocationPermission ? "mappin.slash" : "location.slash")
                .font(.system(size: 54, weight: .light))
                .foregroundStyle(.tertiary)
                .symbolRenderingMode(.hierarchical)
                .padding(.bottom, 4)
            Text(hasLocationPermission ? "Nothing Here Yet" : "Location Needed")
                .font(.title3.weight(.semibold))
            Text(
                hasLocationPermission
                    ? "Be the first to ask something in your area."
                    : "Enable location to see questions near you."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 48)
            Spacer()
            Spacer()
        }
    }

    private var questionList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(filteredQuestions) { question in
                    QuestionCard(
                        question: question,
                        distance: viewModel.distanceToQuestion(question),
                        responseCount: 0,
                        onTap: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            selectedQuestion = question
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: filteredQuestions.map(\.id))
        }
        .refreshable { await viewModel.refresh() }
    }

    private var filteredQuestions: [WRQuestion] {
        guard let urgency = selectedUrgency else { return viewModel.questions }
        return viewModel.questions.filter { $0.urgencyLevel == urgency }
    }

    private var hasLocationPermission: Bool {
        locationService.authorizationStatus == .authorizedWhenInUse ||
        locationService.authorizationStatus == .authorizedAlways
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let label: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(isSelected ? color.opacity(0.15) : Color(.systemGray6))
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? color.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
            )
            .foregroundStyle(isSelected ? color : .secondary)
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

// MARK: - UrgencyLevel UI extensions

extension WRQuestion.UrgencyLevel {
    var color: Color {
        switch self {
        case .info:      return .blue
        case .happening: return .orange
        case .urgent:    return .red
        }
    }

    var icon: String {
        switch self {
        case .info:      return "info.circle"
        case .happening: return "bolt.fill"
        case .urgent:    return "exclamationmark.2"
        }
    }
}

#Preview {
    NavigationStack {
        FeedView(
            user: AppUser(id: "preview", email: "preview@example.com", profileComplete: true),
            locationService: StubLocationService(),
            questionService: StubQuestionService(),
            responseService: StubResponseService(),
            userService: StubUserService(),
            voteService: StubVoteService(),
            onSignOut: {}
        )
    }
}
