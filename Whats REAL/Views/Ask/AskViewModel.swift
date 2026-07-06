//
//  AskViewModel.swift
//  Whats REAL
//

import Foundation

@MainActor
final class AskViewModel: ObservableObject {
    @Published var questionText: String = ""
    @Published var selectedPlace: WRPlace?
    @Published var selectedUrgency: WRQuestion.UrgencyLevel = .info

    @Published private(set) var isPosting: Bool = false
    @Published var errorMessage: String?
    @Published private(set) var successMessage: String?

    private let questionService: QuestionServiceProtocol
    private let userService: UserServiceProtocol
    private let user: AppUser

    var canPost: Bool {
        !questionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && selectedPlace != nil
            && !isPosting
    }

    init(
        user: AppUser,
        questionService: QuestionServiceProtocol,
        userService: UserServiceProtocol,
        mediaService: MediaServiceProtocol
    ) {
        self.user = user
        self.questionService = questionService
        self.userService = userService
    }

    func postQuestion() async -> Bool {
        guard canPost, let place = selectedPlace else {
            errorMessage = "Please fill in all required fields"
            return false
        }

        errorMessage = nil
        successMessage = nil
        isPosting = true
        defer { isPosting = false }

        do {
            let profile = try await userService.fetchProfile(uid: user.id)
            let authorName = profile?.displayName ?? "Anonymous"

            let geohash = Geohash.encode(latitude: place.lat, longitude: place.lng, precision: 9)
            let expiresAt = Date().addingTimeInterval(selectedUrgency.expirationHours * 3600)

            let question = WRQuestion(
                id: UUID().uuidString,
                authorId: user.id,
                authorName: authorName,
                text: questionText.trimmingCharacters(in: .whitespacesAndNewlines),
                photoURL: nil,
                placeId: place.id,
                placeName: place.name,
                placeAddress: place.address,
                lat: place.lat,
                lng: place.lng,
                geohash: geohash,
                urgencyLevel: selectedUrgency,
                createdAt: Date(),
                expiresAt: expiresAt
            )

            _ = try await questionService.createQuestion(question)
            successMessage = "Question posted!"
            resetForm()
            return true
        } catch {
            errorMessage = "Failed to post: \(error.localizedDescription)"
            return false
        }
    }

    func resetForm() {
        questionText = ""
        selectedPlace = nil
        selectedUrgency = .info
    }
}
