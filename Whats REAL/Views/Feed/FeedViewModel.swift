//
//  FeedViewModel.swift
//  Whats REAL
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class FeedViewModel: ObservableObject {
    @Published private(set) var questions: [WRQuestion] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isRefreshing: Bool = false
    @Published var errorMessage: String?

    private let questionService: QuestionServiceProtocol
    private let locationService: any LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var questionSubscription: AnyCancellable?

    init(
        questionService: QuestionServiceProtocol,
        locationService: any LocationServiceProtocol
    ) {
        self.questionService = questionService
        self.locationService = locationService
    }

    deinit {
        cancellables.removeAll()
        questionSubscription?.cancel()
    }

    /// Start observing questions in real-time.
    /// Uses geohash proximity query when location is available; falls back to global.
    func startObserving() {
        guard questionSubscription == nil else { return }

        isLoading = true
        errorMessage = nil

        let publisher: AnyPublisher<[WRQuestion], Error>

        if let location = locationService.currentLocation {
            let prefix = Geohash.prefix(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                precision: 4
            )
            publisher = questionService.observeNearbyQuestions(geohashPrefix: prefix, limit: 100)
        } else {
            publisher = questionService.observeQuestions(limit: 50)
        }

        questionSubscription = publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    self.isLoading = false
                    self.isRefreshing = false
                    if case .failure(let error) = completion {
                        self.errorMessage = "Failed to load questions: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] questions in
                    guard let self else { return }
                    self.isLoading = false
                    self.isRefreshing = false
                    if let location = self.locationService.currentLocation {
                        self.questions = self.filterNearbyQuestions(questions, userLocation: location)
                    } else {
                        self.questions = questions
                    }
                }
            )
    }

    func stopObserving() {
        questionSubscription?.cancel()
        questionSubscription = nil
    }

    func refresh() async {
        isRefreshing = true
        errorMessage = nil

        do {
            let freshQuestions = try await questionService.fetchRecentQuestions(limit: 50)
            if let location = locationService.currentLocation {
                questions = filterNearbyQuestions(freshQuestions, userLocation: location)
            } else {
                questions = freshQuestions
            }
            isRefreshing = false
        } catch {
            isRefreshing = false
            errorMessage = "Failed to refresh: \(error.localizedDescription)"
        }
    }

    func distanceToQuestion(_ question: WRQuestion) -> String? {
        guard let userLocation = locationService.currentLocation else { return nil }
        let questionLocation = CLLocation(latitude: question.lat, longitude: question.lng)
        let distance = userLocation.distance(from: questionLocation)
        return distance < 1000
            ? "\(Int(distance))m away"
            : String(format: "%.1fkm away", distance / 1000)
    }

    private func filterNearbyQuestions(_ questions: [WRQuestion], userLocation: CLLocation) -> [WRQuestion] {
        let maxDistanceMeters: Double = 10_000
        return questions
            .filter { question in
                let loc = CLLocation(latitude: question.lat, longitude: question.lng)
                return userLocation.distance(from: loc) <= maxDistanceMeters
            }
            .sorted { a, b in
                let locA = CLLocation(latitude: a.lat, longitude: a.lng)
                let locB = CLLocation(latitude: b.lat, longitude: b.lng)
                return userLocation.distance(from: locA) < userLocation.distance(from: locB)
            }
    }
}
