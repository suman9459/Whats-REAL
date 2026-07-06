//
//  FirestoreVoteService.swift
//  Whats REAL
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class FirestoreVoteService: @MainActor VoteServiceProtocol {
    private lazy var db = Firestore.firestore()
    private let votesCollection = "votes"

    func castVote(userId: String, responseId: String, voteType: WRVote.VoteType) async throws {
        let voteId = "\(userId)_\(responseId)"
        let vote = WRVote(
            id: voteId,
            userId: userId,
            responseId: responseId,
            voteType: voteType,
            createdAt: Date()
        )
        try db.collection(votesCollection).document(voteId).setData(from: vote)
    }

    func removeVote(userId: String, responseId: String) async throws {
        let voteId = "\(userId)_\(responseId)"
        try await db.collection(votesCollection).document(voteId).delete()
    }

    func getUserVote(userId: String, responseId: String) async throws -> WRVote? {
        let voteId = "\(userId)_\(responseId)"
        let snapshot = try await db.collection(votesCollection).document(voteId).getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: WRVote.self)
    }

    func getVoteCounts(responseId: String) async throws -> VoteCounts {
        let snapshot = try await db.collection(votesCollection)
            .whereField("responseId", isEqualTo: responseId)
            .getDocuments()

        var upvotes = 0
        var downvotes = 0

        for doc in snapshot.documents {
            if let vote = try? doc.data(as: WRVote.self) {
                switch vote.voteType {
                case .upvote:    upvotes += 1
                case .downvote:  downvotes += 1
                }
            }
        }

        return VoteCounts(upvotes: upvotes, downvotes: downvotes)
    }

    func observeVotes(responseId: String) -> AnyPublisher<VoteCounts, Error> {
        let subject = PassthroughSubject<VoteCounts, Error>()

        let listener = db.collection(votesCollection)
            .whereField("responseId", isEqualTo: responseId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }

                guard let snapshot = snapshot else {
                    subject.send(VoteCounts(upvotes: 0, downvotes: 0))
                    return
                }

                var upvotes = 0
                var downvotes = 0

                for doc in snapshot.documents {
                    if let vote = try? doc.data(as: WRVote.self) {
                        switch vote.voteType {
                        case .upvote:    upvotes += 1
                        case .downvote:  downvotes += 1
                        }
                    }
                }

                let counts = VoteCounts(upvotes: upvotes, downvotes: downvotes)
                subject.send(counts)
            }

        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }
}
