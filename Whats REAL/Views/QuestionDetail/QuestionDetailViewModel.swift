//
//  QuestionDetailViewModel.swift
//  Whats REAL
//

import Foundation
import Combine

@MainActor
final class QuestionDetailViewModel: ObservableObject {
    @Published private(set) var responses: [WRResponse] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isSubmitting: Bool = false
    @Published var errorMessage: String?
    @Published var responseText: String = ""

    let question: WRQuestion
    private let responseService: ResponseServiceProtocol
    private let userService: UserServiceProtocol
    private let user: AppUser
    private var cancellables = Set<AnyCancellable>()
    private var responseSubscription: AnyCancellable?

    var responseCount: Int { responses.count }

    var canSubmitText: Bool {
        !responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
    }

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
    }

    deinit {
        cancellables.removeAll()
        responseSubscription?.cancel()
    }

    func startObserving() {
        guard responseSubscription == nil else { return }
        isLoading = true
        errorMessage = nil

        responseSubscription = responseService
            .observeResponses(questionId: question.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        self.errorMessage = "Failed to load responses: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] responses in
                    guard let self else { return }
                    self.isLoading = false
                    self.responses = responses
                }
            )
    }

    func stopObserving() {
        responseSubscription?.cancel()
        responseSubscription = nil
    }

    func submitTextResponse() async -> Bool {
        guard canSubmitText else {
            errorMessage = "Please enter a response"
            return false
        }

        isSubmitting = true
        errorMessage = nil

        do {
            let profile = try await userService.fetchProfile(uid: user.id)
            let responderName = profile?.displayName ?? "Anonymous"

            let response = WRResponse(
                id: UUID().uuidString,
                responderId: user.id,
                responderName: responderName,
                type: .text,
                text: responseText.trimmingCharacters(in: .whitespacesAndNewlines),
                photoURL: nil,
                createdAt: Date(),
                helpfulCount: 0
            )

            try await responseService.addResponse(questionId: question.id, response: response)

            responseText = ""
            isSubmitting = false
            return true
        } catch {
            errorMessage = "Failed to submit response: \(error.localizedDescription)"
            isSubmitting = false
            return false
        }
    }
}
