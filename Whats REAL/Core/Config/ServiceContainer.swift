//
//  ServiceContainer.swift
//  Whats REAL
//

import Foundation

@MainActor
final class ServiceContainer {
    let authService: AuthServiceProtocol
    let userService: UserServiceProtocol
    let placesService: PlacesServiceProtocol
    let questionService: QuestionServiceProtocol
    let responseService: ResponseServiceProtocol
    let mediaService: MediaServiceProtocol
    let notificationService: NotificationServiceProtocol
    let voteService: VoteServiceProtocol
    let locationService: any LocationServiceProtocol

    init(
        authService: AuthServiceProtocol,
        userService: UserServiceProtocol,
        placesService: PlacesServiceProtocol,
        questionService: QuestionServiceProtocol,
        responseService: ResponseServiceProtocol,
        mediaService: MediaServiceProtocol,
        notificationService: NotificationServiceProtocol,
        voteService: VoteServiceProtocol,
        locationService: any LocationServiceProtocol
    ) {
        self.authService = authService
        self.userService = userService
        self.placesService = placesService
        self.questionService = questionService
        self.responseService = responseService
        self.mediaService = mediaService
        self.notificationService = notificationService
        self.voteService = voteService
        self.locationService = locationService
    }

    /// Production container. MKLocalSearch for places — zero cost, no API key.
    static func makeDefault(authService: AuthServiceProtocol) -> ServiceContainer {
        // Share one location service between feed geohash queries and place search bias.
        let locationSvc = CoreLocationService()
        return ServiceContainer(
            authService: authService,
            userService: FirestoreUserService(),
            placesService: MKLocalSearchPlacesService(locationService: locationSvc),
            questionService: FirestoreQuestionService(),
            responseService: FirestoreResponseService(),
            mediaService: FirebaseStorageService(),
            notificationService: StubNotificationService(),
            voteService: FirestoreVoteService(),
            locationService: locationSvc
        )
    }
}
