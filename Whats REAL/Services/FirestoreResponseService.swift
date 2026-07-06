//
//  FirestoreResponseService.swift
//  Whats REAL
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class FirestoreResponseService: @MainActor ResponseServiceProtocol {
    private lazy var db = Firestore.firestore()
    private let responsesCollection = "responses"

    func addResponse(questionId: String, response: WRResponse) async throws {
        let docRef = db.collection(responsesCollection).document(response.id)
        var responseData = try Firestore.Encoder().encode(response)
        responseData["questionId"] = questionId
        try await docRef.setData(responseData)
    }

    func fetchResponses(questionId: String) async throws -> [WRResponse] {
        let snapshot = try await db.collection(responsesCollection)
            .whereField("questionId", isEqualTo: questionId)
            .order(by: "createdAt", descending: false)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: WRResponse.self)
        }
    }

    func observeResponses(questionId: String) -> AnyPublisher<[WRResponse], Error> {
        let subject = PassthroughSubject<[WRResponse], Error>()

        let listener = db.collection(responsesCollection)
            .whereField("questionId", isEqualTo: questionId)
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }

                guard let snapshot = snapshot else {
                    subject.send([])
                    return
                }

                let responses = snapshot.documents.compactMap { doc in
                    try? doc.data(as: WRResponse.self)
                }
                subject.send(responses)
            }

        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }
}
