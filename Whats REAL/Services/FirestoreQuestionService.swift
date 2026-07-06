//
//  FirestoreQuestionService.swift
//  Whats REAL
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class FirestoreQuestionService: @MainActor QuestionServiceProtocol {
    private lazy var db = Firestore.firestore()
    private let collectionPath = "questions"

    func createQuestion(_ question: WRQuestion) async throws -> String {
        let docRef = db.collection(collectionPath).document(question.id)
        do {
            try docRef.setData(from: question)
            return question.id
        } catch {
            throw error
        }
    }

    func fetchRecentQuestions(limit: Int) async throws -> [WRQuestion] {
        let snapshot = try await db.collection(collectionPath)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: WRQuestion.self)
        }
    }

    func observeQuestions(limit: Int) -> AnyPublisher<[WRQuestion], Error> {
        let subject = PassthroughSubject<[WRQuestion], Error>()

        let listener = db.collection(collectionPath)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }

                guard let snapshot = snapshot else {
                    subject.send([])
                    return
                }

                let questions = snapshot.documents.compactMap { doc in
                    try? doc.data(as: WRQuestion.self)
                }
                subject.send(questions)
            }

        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }

    func fetchQuestion(id: String) async throws -> WRQuestion? {
        let snapshot = try await db.collection(collectionPath).document(id).getDocument()
        guard snapshot.exists else { return nil }
        return try? snapshot.data(as: WRQuestion.self)
    }

    func observeNearbyQuestions(geohashPrefix: String, limit: Int) -> AnyPublisher<[WRQuestion], Error> {
        let subject = PassthroughSubject<[WRQuestion], Error>()

        let lower = geohashPrefix
        let upper = geohashPrefix + "\u{FFFF}"

        let listener = db.collection(collectionPath)
            .whereField("geohash", isGreaterThanOrEqualTo: lower)
            .whereField("geohash", isLessThanOrEqualTo: upper)
            .limit(to: limit)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }

                guard let snapshot = snapshot else {
                    subject.send([])
                    return
                }

                let questions = snapshot.documents.compactMap { doc in
                    try? doc.data(as: WRQuestion.self)
                }
                subject.send(questions)
            }

        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }
}
