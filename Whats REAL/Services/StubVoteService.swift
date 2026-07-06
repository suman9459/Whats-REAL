//
//  StubVoteService.swift
//  Whats REAL
//
//  Created by Sai Suman Pothedar on 4/6/26.
//

import Foundation
import Combine

/// Stub implementation of VoteServiceProtocol for testing
@MainActor
final class StubVoteService: VoteServiceProtocol {
    private var votes: [String: WRVote] = [:]
    private var voteCounts: [String: VoteCounts] = [:]
    
    func castVote(userId: String, responseId: String, voteType: WRVote.VoteType) async throws {
        print("📊 [Stub] Casting \(voteType.rawValue) on response \(responseId)")
        
        let voteId = "\(userId)_\(responseId)"
        let vote = WRVote(
            id: voteId,
            userId: userId,
            responseId: responseId,
            voteType: voteType,
            createdAt: Date()
        )
        
        votes[voteId] = vote
        
        // Update counts
        var counts = voteCounts[responseId] ?? VoteCounts(upvotes: 0, downvotes: 0)
        if voteType == .upvote {
            counts.upvotes += 1
        } else {
            counts.downvotes += 1
        }
        voteCounts[responseId] = counts
    }
    
    func removeVote(userId: String, responseId: String) async throws {
        print("📊 [Stub] Removing vote on response \(responseId)")
        
        let voteId = "\(userId)_\(responseId)"
        if let vote = votes[voteId] {
            votes.removeValue(forKey: voteId)
            
            // Update counts
            var counts = voteCounts[responseId] ?? VoteCounts(upvotes: 0, downvotes: 0)
            if vote.voteType == .upvote {
                counts.upvotes = max(0, counts.upvotes - 1)
            } else {
                counts.downvotes = max(0, counts.downvotes - 1)
            }
            voteCounts[responseId] = counts
        }
    }
    
    func getUserVote(userId: String, responseId: String) async throws -> WRVote? {
        let voteId = "\(userId)_\(responseId)"
        return votes[voteId]
    }
    
    func getVoteCounts(responseId: String) async throws -> VoteCounts {
        return voteCounts[responseId] ?? VoteCounts(upvotes: 0, downvotes: 0)
    }
    
    func observeVotes(responseId: String) -> AnyPublisher<VoteCounts, Error> {
        // Return initial counts and complete
        let counts = voteCounts[responseId] ?? VoteCounts(upvotes: 0, downvotes: 0)
        return Just(counts)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
